open! Core_kernel
open! Import

type t =
  | Rotation of int
  | Identity
  | Translate of Point.t

let to_svg_string = function
  | Rotation deg -> sprintf "rotate(%d)" deg
  | Translate { Point.x; y } -> sprintf !"translate(%{strf}, %{strf})" x y
  | Identity -> ""
;;

let inverse = function
  | Rotation deg -> Rotation (-deg)
  | Translate point -> Translate (Point.( * ) (-1.0) point)
  | Identity -> Identity
;;
