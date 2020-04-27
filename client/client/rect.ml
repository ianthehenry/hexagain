open! Core_kernel

type t =
  { origin : Point.t
  ; size : Size.t
  }
[@@deriving sexp_of, fields]

let pad { origin = { Point.x; y }; size = { Size.width; height } } ~horizontal ~vertical =
  { origin = { Point.x = x -. horizontal; y = y -. vertical }
  ; size =
      { Size.width = width +. (2.0 *. horizontal); height = height +. (2.0 *. vertical) }
  }
;;

let left { origin = { x; y = _ }; size = _ } = x
let top { origin = { x = _; y }; size = _ } = y
let width { origin = _; size = { width; height = _ } } = width
let height { origin = _; size = { width = _; height } } = height

let create ~left ~right ~top ~bottom =
  { origin = { Point.x = left; y = top }
  ; size = { Size.width = right -. left; height = bottom -. top }
  }
;;
