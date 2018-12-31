open! Core_kernel

type t =
  | Bridge of Location.t * Location.t
  | Line of Location.t * Location.t
  | Dot of Location.t
  | Star of Location.t
[@@deriving sexp, compare]

let canonical = function
  | Dot x ->
    Dot x
  | Star x ->
    Star x
  | Bridge (a, b) ->
    if Location.( <= ) a b then Bridge (a, b) else Bridge (b, a)
  | Line (a, b) ->
    if Location.( <= ) a b then Line (a, b) else Line (b, a)
;;

let compare a b = compare (canonical a) (canonical b)
