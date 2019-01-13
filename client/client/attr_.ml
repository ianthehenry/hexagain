open! Core_kernel
open! Js_of_ocaml
open! Import
open Incr_dom.Vdom

let view_box rect =
  String.concat
    ~sep:" "
    ( [Rect.left rect; Rect.top rect; Rect.width rect; Rect.height rect]
    |> List.map ~f:strf )
  |> Attr.create "viewBox"
;;

let points points =
  String.concat
    ~sep:","
    (List.concat_map points ~f:(fun {Point.x; y} -> [strf x; strf y]))
  |> Attr.create "points"
;;

let transform transform = Attr.create "transform" (Css_transform.to_svg_string transform)

(* TODO: upstream these *)
type touchEvent = Dom_html.touchEvent

let on_touchend : (touchEvent Js.t -> Event.t) -> Attr.t = Attr.on "touchend"
let on_touchstart : (touchEvent Js.t -> Event.t) -> Attr.t = Attr.on "touchstart"
let on_touchmove : (touchEvent Js.t -> Event.t) -> Attr.t = Attr.on "touchmove"
let on_touchcancel : (touchEvent Js.t -> Event.t) -> Attr.t = Attr.on "touchcancel"
