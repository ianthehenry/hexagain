module Location = Hexagain.Location
module Direction = Hexagain.Direction
module Annotation = Hexagain.Annotation
module Corner = Hexagain.Corner
module Game = Hexagain.Game
module Player = Hexagain.Player
module ID = Hexagain.ID

let strf float =
  let open Js_of_ocaml in
  (Js.number_of_float float)##toString |> Js.to_string
;;

let print str = Js_of_ocaml.Firebug.console##log (Js_of_ocaml.Js.string str)
let print_s sexp = Sexp_pretty.sexp_to_string sexp |> print
