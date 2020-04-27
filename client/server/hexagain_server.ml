open! Core
open Async
open Hexagain
module Rpc = Async_rpc_kernel.Rpc

module State = struct
  type t =
    { games : Game.t ID.Game.Table.t
    ; players : Player.t ID.Player.Table.t
    ; moves : Move.t ID.Move.Table.t
    }
  [@@deriving sexp_of]
end

module Action = struct
  type t = Play of Move.Request.t [@@deriving variants, sexp_of]
end

type t =
  { state : State.t
  ; sequencer : unit Sequencer.t
  }

let handle_action t action =
  Log.Global.sexp [%message "handling" (t.state : State.t) (action : Action.t)];
  Deferred.unit
;;

let implement t protocol query_to_action =
  Rpc.Rpc.implement protocol (fun () query ->
      Throttle.enqueue t.sequencer (fun () -> handle_action t (query_to_action query)))
;;

let run_server t ~port =
  Log.Global.sexp [%message "starting server" (port : int)];
  let implementations =
    Rpc.Implementations.create_exn
      ~implementations:[ implement t Protocol.play Action.play ]
      ~on_unknown_rpc:
        (`Call
          (fun _ ~rpc_tag ~version ->
            Log.Global.sexp [%message "unexpected RPC" (rpc_tag : string) (version : int)];
            `Continue))
  in
  let on_handshake_error =
    `Call
      (fun exn ->
        Log.Global.sexp [%message "handshake error" (exn : exn)];
        Deferred.unit)
  in
  let get_connection_state _ = () in
  let%bind server =
    Websocket_rpc_transport.serve ~port ~f:(fun transport ->
        Rpc.Connection.server_with_close
          transport
          ~connection_state:get_connection_state
          ~on_handshake_error
          ~implementations)
  in
  Tcp.Server.close_finished server
;;

let main =
  let open Command.Let_syntax in
  Command.async
    ~summary:"start the server"
    [%map_open
      let port = flag "--port" (required int) ~doc:"" in
      fun () ->
        let t =
          { sequencer = Sequencer.create ()
          ; state =
              { games = ID.Game.Table.create ()
              ; players = ID.Player.Table.create ()
              ; moves = ID.Move.Table.create ()
              }
          }
        in
        run_server t ~port]
;;

let () = Command.run main
