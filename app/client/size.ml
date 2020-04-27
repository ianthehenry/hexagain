open! Core_kernel

type t =
  { width : float
  ; height : float
  }
[@@deriving sexp_of, fields]
