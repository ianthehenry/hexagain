open Core

module T = struct
  type t = int [@@deriving sexp_of, compare, hash]
end

include T
include Hashable.Make_plain (T)
