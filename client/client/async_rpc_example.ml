open Core_kernel
open Async_kernel
open Async_rpc_kernel
module Url = Js_of_ocaml.Url

let scheme = if String.( = ) Url.Current.protocol "https:" then "wss" else "ws"

let with_rpc_conn f ~host ~port =
  match%bind
    Async_js.Rpc.Connection.client ~uri:(Uri.make ~host ~port ~scheme ()) ()
  with
  | Error error ->
    eprintf !"%{sexp: Error.t}" error;
    Deferred.unit
  | Ok connection ->
    f connection
;;

let say_hello ~host ~port =
  with_rpc_conn
    (fun conn ->
      let%bind () =
        Rpc.Rpc.dispatch_exn
          Hexagain.Protocol.play
          conn
          {Hexagain.Protocol.Play.game_id = 0; action = Swap}
      in
      printf "one down\n%!";
      let%bind () =
        Rpc.Rpc.dispatch_exn
          Hexagain.Protocol.play
          conn
          {Hexagain.Protocol.Play.game_id = 0; action = Swap}
      in
      printf "all done\n%!";
      Deferred.unit )
    ~host
    ~port
;;

let () =
  Async_js.init ();
  don't_wait_for (say_hello ~host:"localhost" ~port:1234)
;;
