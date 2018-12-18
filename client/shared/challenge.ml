open! Core_kernel

module Id = struct
  type t = int [@@deriving sexp_of, bin_io]
end

type t =
  { id : Id.t
  ; options : Game_options.t
  ; challenger_id : Player_id.t
  ; opponent_id : Player_id.t
  ; opponent_starts : bool }
[@@deriving sexp_of, bin_io]
