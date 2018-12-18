open! Core
open Async
module Rpc = Async_rpc_kernel.Rpc

let play_impl () play =
  Log.Global.sexp [%message "play" (play : Hexagain.Protocol.Play.t)];
  Deferred.unit
;;

let implementations = [Rpc.Rpc.implement Hexagain.Protocol.play play_impl]

let run_server ~port =
  Log.Global.sexp [%message "starting server" (port : int)];
  let implementations =
    Rpc.Implementations.create_exn
      ~implementations
      ~on_unknown_rpc:
        (`Call
          (fun _ ~rpc_tag ~version ->
            Log.Global.sexp
              [%message "unexpected RPC" (rpc_tag : string) (version : int)];
            `Continue ))
  in
  let on_handshake_error =
    `Call
      (fun exn ->
        Log.Global.sexp [%message "handshake error" (exn : exn)];
        Deferred.unit )
  in
  let get_connection_state _ = () in
  let%bind server =
    Web_transport.serve ~port ~f:(fun transport ->
        Rpc.Connection.server_with_close
          transport
          ~connection_state:get_connection_state
          ~on_handshake_error
          ~implementations )
  in
  Tcp.Server.close_finished server
;;

let main =
  let open Command.Let_syntax in
  Command.async
    ~summary:"start the server"
    [%map_open
      let port = flag "--port" (required int) ~doc:"" in
      fun () -> run_server ~port]
;;

let () = Command.run main
