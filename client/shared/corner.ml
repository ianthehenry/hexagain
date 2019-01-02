open! Core_kernel

type t =
  | WE
  | ED
  | DX
  | XZ
  | ZA
  | AW
[@@deriving sexp_of, compare, enumerate]

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

let clockwise = function
  | WE ->
    ED
  | ED ->
    DX
  | DX ->
    XZ
  | XZ ->
    ZA
  | ZA ->
    AW
  | AW ->
    WE
;;

let counter_clockwise = function
  | ED ->
    WE
  | DX ->
    ED
  | XZ ->
    DX
  | ZA ->
    XZ
  | AW ->
    ZA
  | WE ->
    AW
;;

let inverse = function
  | ED ->
    ZA
  | DX ->
    AW
  | XZ ->
    WE
  | ZA ->
    ED
  | AW ->
    DX
  | WE ->
    XZ
;;
