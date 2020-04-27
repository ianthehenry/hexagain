open! Core_kernel

module Time_ns = struct
  include Time_ns

  (* TODO: why the heck isn't this in Core_kernel? *)
  let sexp_of_t t =
    t
    |> Time_ns.to_int_ns_since_epoch
    |> float
    |> Time.Span.of_ns
    |> Time.of_span_since_epoch
    |> Time.to_date_ofday ~zone:Time.Zone.utc
    |> [%sexp_of: Date.t * Time.Ofday.t]
  ;;
end

module Request = struct
  type t =
    { action : Action.t
    ; game_id : ID.Game.t
    }
  [@@deriving sexp_of, bin_io]
end

type t =
  { id : ID.Move.t
  ; action : Action.t
  ; at : Time_ns.t
  ; player_id : ID.Player.t
  ; game_id : ID.Game.t
  }
[@@deriving sexp_of, bin_io]
