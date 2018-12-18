open! Core_kernel

type t =
  | WE
  | ED
  | DX
  | XZ
  | ZA
  | AW
[@@deriving sexp_of]

let of_direction : Direction.t -> t list = function
  | W ->
    [WE; AW]
  | E ->
    [WE; ED]
  | D ->
    [ED; DX]
  | X ->
    [DX; XZ]
  | Z ->
    [XZ; ZA]
  | A ->
    [ZA; AW]
;;
