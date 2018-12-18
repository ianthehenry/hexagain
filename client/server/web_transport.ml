open Core
open Async
module Rpc_kernel = Async_rpc_kernel
module WS = Websocket_async

let ping_interval = Time_ns.Span.of_sec 20.0
let timeout_interval = Time_ns.Span.scale_int ping_interval 2
let ping = WS.Frame.create ~opcode:Ping ()
let pong = WS.Frame.create ~opcode:Pong ()
let close_ack = WS.Frame.close 0
let close_timeout = WS.Frame.close 1

let make_websocket_transport reader writer =
  let app_to_ws, to_client = Pipe.create () in
  let from_client, ws_to_app = Pipe.create () in
  let disconnect close_reason =
    Pipe.write_without_pushback to_client close_reason;
    Pipe.close to_client
  in
  let disconnected = Pipe.closed from_client in
  Clock_ns.every' ~stop:disconnected ping_interval (fun () ->
      Pipe.write_if_open to_client ping );
  let disconnect_event =
    Clock_ns.Event.run_after timeout_interval disconnect close_timeout
  in
  upon disconnected (Clock_ns.Event.abort_if_possible disconnect_event);
  let strings_from_client =
    Pipe.filter_map from_client ~f:(fun (frame : Websocket.Frame.t) ->
        Clock_ns.Event.reschedule_after disconnect_event timeout_interval
        |> (ignore : (unit, unit) Time_source.Event.Reschedule_result.t -> unit);
        match frame.opcode with
        | Close ->
          disconnect close_ack;
          None
        | Binary ->
          Some frame.content
        | Ping ->
          Pipe.write_without_pushback to_client pong;
          None
        | Pong ->
          None
        | _ ->
          (* CR ihenry: log something here? *)
          None )
  in
  let strings_to_client =
    Pipe.create_writer (fun reader ->
        Pipe.transfer reader to_client ~f:(fun content ->
            WS.Frame.create ~opcode:Binary ~content () ) )
  in
  let ws_log =
    Log.create ~level:`Debug ~output:[Log.Output.stdout ()] ~on_error:`Raise
  in
  (* CR ihenry: do some sort of auth here? *)
  let server_finished =
    match%map WS.server ~log:ws_log ~app_to_ws ~ws_to_app ~reader ~writer () with
    | Error error ->
      Log.Global.sexp [%message "WS completed with error" (error : Error.t)]
    | Ok () ->
      ()
  in
  let transport =
    Rpc_kernel.Pipe_transport.create
      Rpc_kernel.Pipe_transport.Kind.string
      strings_from_client
      strings_to_client
  in
  server_finished, transport
;;

let serve ~port ~f =
  Tcp.Server.create
    (Tcp.Where_to_listen.of_port port)
    ~on_handler_error:
      (`Call
        (fun _ exn -> Log.Global.sexp [%message "web TCP handler error" (exn : exn)]))
    (fun _ reader writer ->
      let server_finished, transport = make_websocket_transport reader writer in
      Deferred.any_unit [server_finished; f transport] )
;;
