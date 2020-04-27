open! Core_kernel
open! Import

type t =
  | Move of Point.t
  | Quadratic of Point.t * Point.t
[@@deriving sexp_of]

let to_svg_string t =
  String.concat
    ~sep:" "
    (match t with
    | Move { Point.x; y } -> [ "M"; strf x; strf y ]
    | Quadratic ({ Point.x; y }, { Point.x = x'; y = y' }) ->
      [ "Q"; strf x; strf y; ","; strf x'; strf y' ])
;;
