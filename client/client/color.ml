open! Core_kernel
open! Import

type t =
  | Black
  | White
[@@deriving sexp, compare]
