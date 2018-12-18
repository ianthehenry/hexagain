open! Core_kernel

type t =
  { size : int
  ; handicap : Handicap.t }
[@@deriving sexp_of, bin_io]
