open! Core_kernel
module ID = ID.Move

type t =
  { id : ID.t
  ; name : string
  ; email : string }
[@@deriving sexp_of, bin_io]
