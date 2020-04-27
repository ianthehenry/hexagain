open! Core_kernel
open! Import
open Incr_dom.Vdom

let circle { Point.x; y } radius attrs =
  Node.create_svg
    "circle"
    ([ Attr.create "cx" (strf x)
     ; Attr.create "cy" (strf y)
     ; Attr.create "r" (strf radius)
     ]
    @ attrs)
    []
;;

let text str attrs = Node.create_svg "text" attrs [ Node.text str ]

let path path_instructions attrs =
  let d =
    String.concat ~sep:" " (List.map path_instructions ~f:Path_instruction.to_svg_string)
  in
  Node.create_svg "path" ([ Attr.create "d" d ] @ attrs) []
;;

let line { Point.x = x1; y = y1 } { Point.x = x2; y = y2 } attrs =
  Node.create_svg
    "line"
    ([ Attr.create "x1" (strf x1)
     ; Attr.create "y1" (strf y1)
     ; Attr.create "x2" (strf x2)
     ; Attr.create "y2" (strf y2)
     ]
    @ attrs)
    []
;;

let polygon points attrs = Node.create_svg "polygon" ([ Attr_.points points ] @ attrs) []
