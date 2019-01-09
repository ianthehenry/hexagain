open! Core_kernel
open! Import

module Authenticated = struct
  type t = {player : ID.Player.t} [@@deriving sexp_of, compare]
end

type t =
  | Anonymous
  | Authenticated of Authenticated.t
[@@deriving sexp_of, compare]
