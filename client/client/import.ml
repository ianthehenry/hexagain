module Location = Hexagain.Location
module Direction = Hexagain.Direction
module Annotation = Hexagain.Annotation
module Corner = Hexagain.Corner

let strf float =
  let open Js_of_ocaml in
  (Js.number_of_float float)##toString |> Js.to_string
;;
