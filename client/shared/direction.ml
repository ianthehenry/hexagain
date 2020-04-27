open! Core_kernel

type t =
  | W
  | E
  | A
  | D
  | Z
  | X
[@@deriving sexp_of, enumerate]

let inverse = function
  | W -> X
  | E -> Z
  | A -> D
  | D -> A
  | Z -> E
  | X -> W
;;
