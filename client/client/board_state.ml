open! Core_kernel
open! Import

type t =
  { dimensions : Dimensions.t
  ; rotation : Rotation.t sexp_option
  ; annotations : Annotation.t list [@sexp_drop_default] [@default []]
  ; stones : (Color.t * Location.t) list
  ; disabled : Location.Set.t
         [@sexp_drop_if Location.Set.is_empty] [@default Location.Set.empty] }
[@@deriving sexp, compare]
