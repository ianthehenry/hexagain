open! Core_kernel
open Async_rpc_kernel

module Challenge_parameters = struct
  type t =
    { options : Game_options.t
    ; opponent_id : ID.Player.t
    ; opponent_starts : bool }
  [@@deriving sexp_of, bin_io]
end

let play =
  Rpc.Rpc.create
    ~name:"play"
    ~version:0
    ~bin_query:Move.Request.bin_t
    ~bin_response:Unit.bin_t
;;

let create_challenge =
  Rpc.Rpc.create
    ~name:"create-challenge"
    ~version:0
    ~bin_query:Challenge_parameters.bin_t
    ~bin_response:Challenge.bin_t
;;

let accept_challenge =
  Rpc.Rpc.create
    ~name:"accept-challenge"
    ~version:0
    ~bin_query:ID.Challenge.bin_t
    ~bin_response:Game.bin_t
;;
