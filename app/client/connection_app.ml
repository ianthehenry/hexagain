open! Core_kernel
open! Incr_dom
open! Js_of_ocaml
open! Import
open Async_kernel
open Async_rpc_kernel
module Url = Js_of_ocaml.Url

module Socket_state = struct
  type t =
    | Disconnected
    | Connecting
    | Connected
    | Error
  [@@deriving sexp_of, compare]
end

module Model = struct
  module Authenticated = struct
    type t =
      { player_id : ID.Player.t
      ; socket_state : Socket_state.t
      }
    [@@deriving sexp_of, fields, compare]
  end

  type t =
    | Anonymous
    | Authenticated of Authenticated.t
  [@@deriving sexp_of, compare]

  let preview_authenticated = function
    | Anonymous -> None
    | Authenticated authenticated -> Some authenticated
  ;;

  let cutoff = [%compare.equal: t]
end

module Action = struct
  type t = Set_socket_state of Socket_state.t [@@deriving sexp_of, compare]
end

module State = struct
  type t = { rpc_connection : Rpc.Connection.t Or_error.t Mvar.Read_write.t }
  [@@deriving fields]
end

let apply_action model action _state ~schedule_action:_ =
  match (action : Action.t) with
  | Set_socket_state socket_state ->
    (match (model : Model.t) with
    | Anonymous -> failwith "socket state changed while anonymous"
    | Authenticated model -> Model.Authenticated { model with socket_state })
;;

let view_authenticated (model : Model.Authenticated.t Incr.t) =
  let open Incr.Let_syntax in
  let open Vdom in
  let socket_state =
    let%map socket_state = model >>| Model.Authenticated.socket_state in
    let text = sprintf !"%{sexp: Socket_state.t}" socket_state in
    Node.div [] [ Node.text text ]
  in
  let%map socket_state = socket_state in
  Node.div [] [ socket_state ]
;;

(* TODO: So, this is interesting, and I don't really know how to think about
   incremental variants in general. But this might work? Maybe? Need to figure
   out if there's a "right" way to do this. *)
let incr_value_map
    (value : 'a option Incr.t)
    ~(f : 'a Incr.t -> 'b Incr.t)
    ~(default : 'b Incr.t)
  =
  let open Incr.Let_syntax in
  Incr.if_
    (value >>| Option.is_some)
    ~then_:(f (value >>| fun x -> Option.value_exn x))
    ~else_:default
;;

let view (model : Model.t Incr.t) ~inject:_ =
  let open Incr.Let_syntax in
  let open Vdom in
  incr_value_map
    (model >>| Model.preview_authenticated)
    ~f:view_authenticated
    ~default:(return (Node.div [] [ Node.text "anon" ]))
;;

let connect_loop state ~schedule_action =
  let max_reconnect_delay = Time_ns.Span.minute in
  let initial_reconnect_delay = Time_ns.Span.second in
  let scheme = if String.( = ) Url.Current.protocol "https:" then "wss" else "ws" in
  let host = "localhost" in
  let port = 1234 in
  let rec loop ~reconnect_delay =
    let open Async_kernel in
    schedule_action (Action.Set_socket_state Connecting);
    match%bind
      Async_js.Rpc.Connection.client ~uri:(Uri.make ~host ~port ~scheme ()) ()
    with
    | Error error ->
      eprintf !"error connecting %{sexp: Error.t}" error;
      schedule_action (Action.Set_socket_state Error);
      (* TODO: wait a while before reconnecting *)
      let%bind () = Clock_ns.after reconnect_delay in
      loop
        ~reconnect_delay:
          (Time_ns.Span.min
             max_reconnect_delay
             (Time_ns.Span.scale_int reconnect_delay 2))
    | Ok connection ->
      Mvar.set (State.rpc_connection state) (Or_error.return connection);
      schedule_action (Action.Set_socket_state Connected);
      let%bind () = Async_js.Rpc.Connection.close_finished connection in
      print "connection closed";
      Mvar.take_now_exn (State.rpc_connection state)
      |> (ignore : Rpc.Connection.t Or_error.t -> unit);
      schedule_action (Action.Set_socket_state Disconnected);
      loop ~reconnect_delay:initial_reconnect_delay
  in
  don't_wait_for (loop ~reconnect_delay:initial_reconnect_delay)
;;

let on_startup ~schedule_action _ =
  let state = { State.rpc_connection = Mvar.create () } in
  connect_loop state ~schedule_action;
  Deferred.return state
;;

let create model ~old_model:_ ~inject =
  let open Incr.Let_syntax in
  let%map apply_action =
    let%map model = model in
    apply_action model
  and view = view model ~inject
  and model = model in
  Component.create ~apply_action model view
;;
