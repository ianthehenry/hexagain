open! Core_kernel
open! Async_kernel
open! Incr_dom
open! Js_of_ocaml
open! Import

let query selector =
  Dom_html.document##querySelectorAll (Js.string selector) |> Dom.list_of_nodeList
;;

let text_of element =
  element##.textContent |> Js.Opt.to_option |> Option.value_exn |> Js.to_string
;;

module Move_abbreviation = struct
  type t =
    { dimensions : Dimensions.t
    ; rotation : Rotation.t option[@sexp.option]
    ; initial_stones : int
    ; moves : Location.t list
    ; disabled : Location.Set.t
           [@sexp_drop_if Location.Set.is_empty] [@default Location.Set.empty] }
  [@@deriving sexp, compare]

  let to_board_states {dimensions; rotation; initial_stones; moves; disabled} =
    let stones =
      []
      :: List.folding_mapi moves ~init:[] ~f:(fun index stones location ->
             let color : Color.t =
               match index % 2 with
               | 0 ->
                 Black
               | 1 ->
                 White
               | _ ->
                 assert false
             in
             let stones = (color, location) :: stones in
             stones, stones )
    in
    let states =
      List.map stones ~f:(fun stones ->
          {Board_state.dimensions; rotation; disabled; annotations = []; stones} )
    in
    List.drop states initial_stones
  ;;
end

let parse_model text =
  let sexp = Sexp.of_string text in
  let states =
    try [[%of_sexp: Board_state.t] sexp] with _ ->
      (try [%of_sexp: Move_abbreviation.t] sexp |> Move_abbreviation.to_board_states
       with _ -> [%of_sexp: Board_state.t list] sexp)
  in
  Board.Model.create states
;;

module Route = struct
  type t =
    | Game of ID.Game.t
    | Home
    | Other
  [@@deriving sexp_of]

  let of_pathname pathname =
    Option.try_with (fun () ->
        match
          pathname |> String.strip ~drop:(Char.( = ) '/') |> String.split ~on:'/'
        with
        | ["game"] ->
          (* Sigh. So using the hugo dev server is really nice, but it won't let
             us route to dynamic URLs, so we do this to test... *)
          Game (ID.Game.of_string "0")
        | ["game"; id] ->
          Game (ID.Game.of_string id)
        | [""] ->
          Home
        | _ ->
          Other )
    |> Option.value ~default:Other
  ;;
end

let main =
  let%bind () = Async_js.document_loaded () in
  let route =
    Dom_html.window##.location##.pathname |> Js.to_string |> Route.of_pathname
  in
  (match route with
  | Game game_id ->
    Incr_dom.Start_app.start
      (module Connection_app)
      ~bind_to:(Dom_html.getElementById_exn "status" :> Dom.node Js.t)
      ~initial_model:
        Connection_app.Model.(
          Authenticated
            { Authenticated.player_id = ID.Player.of_string "0"
            ; socket_state = Connection_app.Socket_state.Disconnected });
    (* TODO, obviously... *)
    ignore game_id;
    let game_model =
      Board.Model.create
        [ { Board_state.dimensions = {Dimensions.width = 11; height = 11}
          ; rotation = None
          ; annotations = []
          ; stones = []
          ; disabled = Location.Set.empty } ]
    in
    let root = Dom_html.getElementById_exn "game-container" in
    Incr_dom.Start_app.start
      (module Board)
      ~bind_to:(root :> Dom.node Js.t)
      ~initial_model:game_model
  | Other
  | Home ->
    query {|script[type="application/json"]|}
    |> List.iter ~f:(fun element ->
           Incr_dom.Start_app.start
             (module Board)
             ~bind_to:(element :> Dom.node Js.t)
             ~initial_model:(parse_model (text_of element)) ));
  Deferred.unit
;;

let () =
  Async_js.init ();
  don't_wait_for main
;;
