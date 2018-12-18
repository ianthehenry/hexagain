open! Core_kernel

module Id = struct
  type t = int [@@deriving sexp_of, bin_io]
end

type t =
  { id : Id.t
  ; config : Game_options.t
  ; black_player : Player_id.t
  ; white_player : Player_id.t
  ; stones : Location.t list
  ; winner : Player_id.t option }
[@@deriving sexp_of, bin_io]

(* TODO: this should take into account handicap *)
let whose_turn_is_it {white_player; black_player; stones; _} =
  match List.length stones % 2 with
  | 0 ->
    black_player
  | 1 ->
    white_player
  | _ ->
    assert false
;;

let other_player_exn game player =
  let {white_player; black_player; _} = game in
  if [%compare.equal: Player_id.t] player white_player
  then black_player
  else if [%compare.equal: Player_id.t] player black_player
  then white_player
  else raise_s [%message "unknown player" (game : t) (player : Player_id.t)]
;;

(* TODO: this should take into account handicap *)
let winning_player {stones; config; _} =
  if List.length stones / 2 < config.size
  then None
  else (* slow algorithm to find winner *)
    None
;;

let apply_action t = function
  | Action.Swap ->
    {t with black_player = t.white_player; white_player = t.black_player}
  | Action.Drop location ->
    let t' = {t with stones = location :: t.stones} in
    {t' with winner = winning_player t'}
  | Action.Resign ->
    {t with winner = Some (other_player_exn t (whose_turn_is_it t))}
;;
