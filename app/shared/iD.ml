open! Core_kernel

module type S = sig
  type t [@@deriving sexp_of, bin_io, compare]

  include Hashable.S_plain with type t := t
  include Comparable.S_plain with type t := t
  include Stringable.S with type t := t
end

module Make () = struct
  module T = struct
    type t = int [@@deriving sexp, bin_io, compare, hash]
  end

  include T
  include Hashable.Make_plain (T)
  include Comparable.Make_plain (T)
  include Sexpable.To_stringable (T)
end

module Game = Make ()
module Player = Make ()
module Move = Make ()
module Challenge = Make ()
