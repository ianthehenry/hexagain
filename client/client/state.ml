open! Core_kernel
open! Import

module Socket_state = struct
  type t =
    | Disconnected
    | Connecting
    | Connected
  [@@deriving sexp_of, compare]
end

module Authenticated = struct
  type t =
    { player : ID.Player.t
    ; socket_state : Socket_state.t }
  [@@deriving sexp_of, compare]
end

type t =
  | Anonymous
  | Authenticated of Authenticated.t
[@@deriving sexp_of, compare]
