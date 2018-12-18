open! Core_kernel

type t = int [@@deriving sexp_of, bin_io, compare]
