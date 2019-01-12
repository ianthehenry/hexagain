open! Core_kernel
open! Js_of_ocaml

let strf float = (Js.number_of_float float)##toString |> Js.to_string
let print str = Firebug.console##log (Js.string str)
let print_s sexp = Sexp_pretty.sexp_to_string sexp |> print
let both (a, b) ~f = f a, f b
let testing pred x = if pred x then Some x else None
let twice x = x, x
let smaller ~compare a b = if compare a b < 0 then a else b
let larger ~compare a b = if compare a b < 0 then b else a
let append_some x list = Option.value_map x ~default:list ~f:(fun x -> list @ [x])
let option_trying f x = Option.try_with (fun () -> f x)
let cons_some opt list = Option.value_map opt ~default:list ~f:(fun x -> x :: list)
let cons_if bool x xs = if bool then x :: xs else xs

let min_and_max_elt_exn list ~compare =
  List.fold
    ~init:(twice (List.hd_exn list))
    (List.tl_exn list)
    ~f:(fun (min, max) el -> smaller ~compare min el, larger ~compare max el)
;;
