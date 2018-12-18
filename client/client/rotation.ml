open! Core_kernel
open! Import

type t =
  | Flat
  | Rotated
[@@deriving sexp, compare]
