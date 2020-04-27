open! Core_kernel

module type S = sig
  type t [@@deriving sexp_of, bin_io, compare]

  include Hashable.S_plain with type t := t
  include Comparable.S_plain with type t := t
  include Stringable.S with type t := t
end

module Game : S
module Move : S
module Player : S
module Challenge : S
