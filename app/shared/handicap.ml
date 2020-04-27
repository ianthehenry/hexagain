open! Core_kernel

type t =
  | No_handicap
  | No_swap
  | One_extra_piece
[@@deriving sexp_of, bin_io]
