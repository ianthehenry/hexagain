open! Core_kernel

type t =
  | Swap
  | Place_stone of Location.t
  | Resign
[@@deriving sexp_of, bin_io]
