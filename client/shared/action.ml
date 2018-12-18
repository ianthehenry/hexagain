open! Core_kernel

type t =
  | Swap
  | Drop of Location.t
  | Resign
[@@deriving sexp_of, bin_io]
