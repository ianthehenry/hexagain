open! Core_kernel
open! Import

type t =
  { width : int
  ; height : int }
[@@deriving compare]

let to_string {width; height} = sprintf "%dx%d" width height
let both (a, b) ~f = f a, f b

let of_string str =
  let width, height = String.lsplit2_exn str ~on:'x' |> both ~f:int_of_string in
  {width; height}
;;

let sexp_of_t t = Sexp.Atom (to_string t)

let t_of_sexp = function
  | Sexp.Atom str ->
    of_string str
  | _ ->
    failwith "invalid"
;;
