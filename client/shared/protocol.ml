open! Core_kernel
open Async_rpc_kernel

module Play = struct
  type t =
    { game_id : Game.Id.t
    ; action : Action.t }
  [@@deriving sexp_of, bin_io]
end

module Challenge_parameters = struct
  type t =
    { options : Game_options.t
    ; opponent_id : Player_id.t
    ; opponent_starts : bool }
  [@@deriving sexp_of, bin_io]
end

let play =
  Rpc.Rpc.create ~name:"play" ~version:0 ~bin_query:Play.bin_t ~bin_response:Unit.bin_t
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
    ~bin_query:Challenge.Id.bin_t
    ~bin_response:Game.bin_t
;;
