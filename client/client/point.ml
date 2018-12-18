open! Core_kernel

type t =
  { x : float
  ; y : float }
[@@deriving sexp_of, fields]

let ( + ) {x; y} {x = x'; y = y'} = {x = x +. x'; y = y +. y'}
let ( - ) {x; y} {x = x'; y = y'} = {x = x -. x'; y = y -. y'}
let ( * ) s {x; y} = {x = x *. s; y = y *. s}
let average weight a b = (weight * a) + ((1.0 -. weight) * b)
let zero = {x = 0.0; y = 0.0}
