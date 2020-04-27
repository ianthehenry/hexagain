open! Core_kernel

type t =
  { id : ID.Challenge.t
  ; options : Game_options.t
  ; challenger_id : ID.Player.t
  ; opponent_id : ID.Player.t
  ; opponent_starts : bool
  }
[@@deriving sexp_of, bin_io]
