open! Core_kernel
open! Incr_dom
open! Import
open! Js_of_ocaml

let render_sexps = false
let render_labels = false

module Transform = struct
  type t =
    | Rotation of int
    | Identity
    | Translate of Point.t

  let to_svg_string = function
    | Rotation deg ->
      sprintf "rotate(%d)" deg
    | Translate {Point.x; y} ->
      sprintf !"translate(%{strf}, %{strf})" x y
    | Identity ->
      ""
  ;;

  let inverse = function
    | Rotation deg ->
      Rotation (-deg)
    | Translate point ->
      Translate (Point.( * ) (-1.0) point)
    | Identity ->
      Identity
  ;;
end

module Action = struct
  type t =
    | Next_state
    | Prev_state
    | Start_annotation of Location.t
    | End_annotation of Location.t
    | Annotation_between of Location.t * Location.t
    | Toggle_interaction
  [@@deriving sexp_of]

  let should_log _ = true
end

module State = struct
  type t = unit
end

module Attr_ = struct
  open Vdom

  let view_box rect =
    String.concat
      ~sep:" "
      ( [Rect.left rect; Rect.top rect; Rect.width rect; Rect.height rect]
      |> List.map ~f:strf )
    |> Attr.create "viewBox"
  ;;

  let points points =
    String.concat
      ~sep:","
      (List.concat_map points ~f:(fun {Point.x; y} -> [strf x; strf y]))
    |> Attr.create "points"
  ;;

  let transform transform = Attr.create "transform" (Transform.to_svg_string transform)

  (* TODO: upstream these *)
  type touchEvent = Dom_html.touchEvent

  let on_touchend : (touchEvent Js.t -> Event.t) -> Attr.t = Attr.on "touchend"
  let on_touchstart : (touchEvent Js.t -> Event.t) -> Attr.t = Attr.on "touchstart"
  let on_touchmove : (touchEvent Js.t -> Event.t) -> Attr.t = Attr.on "touchmove"
  let on_touchcancel : (touchEvent Js.t -> Event.t) -> Attr.t = Attr.on "touchcancel"
end

let mobile_friendly_button text action attrs ~inject =
  let open Vdom in
  Node.button
    ( Attr.on "touchstart" (const Event.Ignore)
    :: Attr.on_click (fun _ -> inject action)
    :: attrs )
    [Node.text text]
;;

module Svg = struct
  open Vdom

  let circle {Point.x; y} radius attrs =
    Node.svg
      "circle"
      ( [ Attr.create "cx" (strf x)
        ; Attr.create "cy" (strf y)
        ; Attr.create "r" (strf radius) ]
      @ attrs )
      []
  ;;

  let text str attrs = Node.svg "text" attrs [Node.text str]

  let path path_instructions attrs =
    let d =
      String.concat
        ~sep:" "
        (List.map path_instructions ~f:Path_instruction.to_svg_string)
    in
    Node.svg "path" ([Attr.create "d" d] @ attrs) []
  ;;

  let line {Point.x = x1; y = y1} {Point.x = x2; y = y2} attrs =
    Node.svg
      "line"
      ( [ Attr.create "x1" (strf x1)
        ; Attr.create "y1" (strf y1)
        ; Attr.create "x2" (strf x2)
        ; Attr.create "y2" (strf y2) ]
      @ attrs )
      []
  ;;

  let polygon points attrs = Node.svg "polygon" ([Attr_.points points] @ attrs) []
end

module Board_state = struct
  type t =
    { dimensions : Dimensions.t
    ; rotation : Rotation.t sexp_option
    ; annotations : Annotation.t list [@sexp_drop_default] [@default []]
    ; stones : (Color.t * Location.t) list
    ; disabled : Location.Set.t
           [@sexp_drop_if Location.Set.is_empty] [@default Location.Set.empty] }
  [@@deriving sexp, compare]
end

let default_rotation = Rotation.Rotated
let radius = 0.5
let apothem = 0.5 *. sqrt 3.0 *. radius
let spacing = apothem *. sqrt 3.0

let color_class = function
  | Color.White ->
    "white"
  | Color.Black ->
    "black"
;;

let point_at_corner corner ~radius =
  let corner_int =
    match (corner : Corner.t) with
    | WE ->
      4
    | ED ->
      5
    | DX ->
      0
    | XZ ->
      1
    | ZA ->
      2
    | AW ->
      3
  in
  let angle = (float corner_int +. 0.5) *. Float.pi *. 2.0 /. 6.0 in
  {Point.x = Float.cos angle *. radius; y = Float.sin angle *. radius}
;;

let position (location : Location.t) =
  { Point.x = (float (location.col * 2) *. apothem) +. (apothem *. float location.row)
  ; y = spacing *. float location.row }
;;

let get_hex =
  let points = List.map Corner.all ~f:(point_at_corner ~radius:(radius *. 0.9)) in
  fun location attrs ->
    Svg.polygon points (Attr_.transform (Translate (position location)) :: attrs)
;;

let shared_neighbors a b =
  Set.inter (Location.neighbors a) (Location.neighbors b) |> Set.to_list
;;

let render_annotation annotation =
  let open Vdom in
  match (annotation : Annotation.t) with
  | Bridge (from, to_) ->
    (match shared_neighbors from to_ with
    | [span; span'] ->
      let span_direction = Location.direction_between_exn span span' in
      let control1 =
        Point.average
          0.9
          (position span)
          (position (Location.in_direction span (Direction.inverse span_direction)))
      in
      let control2 =
        Point.average
          0.9
          (position span')
          (position (Location.in_direction span' span_direction))
      in
      Svg.path
        [ Path_instruction.Move (position from)
        ; Path_instruction.Quadratic (control1, position to_)
        ; Path_instruction.Quadratic (control2, position from) ]
        [Attr.class_ "annotation"]
    | _ ->
      failwith "illegal bridge")
  | Line (from, to_) ->
    Svg.line (position from) (position to_) [Attr.class_ "annotation"]
  | Dot at ->
    Svg.circle (position at) 0.1 [Attr.class_ "annotation"]
  | Star at ->
    let corner_line first_corner =
      let line_radius = 0.3 *. apothem in
      Svg.line
        (point_at_corner ~radius:line_radius first_corner)
        (point_at_corner ~radius:line_radius (Corner.inverse first_corner))
        [Attr_.transform (Rotation 30)]
    in
    Node.svg
      "g"
      [Attr.class_ "annotation"; Attr_.transform (Translate (position at))]
      [corner_line DX; corner_line XZ; corner_line ZA]
;;

let testing pred x = if pred x then Some x else None

module Edge = struct
  module T = struct
    type t =
      | Top
      | Bottom
      | Left
      | Right
    [@@deriving sexp, compare, enumerate]
  end

  include T
  include Comparable.Make (T)

  let of_location (dimensions : Dimensions.t) (location : Location.t) =
    if Int.( = ) location.row dimensions.height
    then Some Bottom
    else if Int.( = ) location.row (-1)
    then Some Top
    else if Int.( = ) location.col dimensions.width
    then Some Right
    else if Int.( = ) location.col (-1)
    then Some Left
    else None
  ;;

  let color : t -> Color.t = function
    | Bottom
    | Top ->
      Black
    | Right
    | Left ->
      White
  ;;
end

let twice x = x, x
let smaller ~compare a b = if compare a b < 0 then a else b
let larger ~compare a b = if compare a b < 0 then b else a

let min_and_max_elt_exn list ~compare =
  List.fold
    ~init:(twice (List.hd_exn list))
    (List.tl_exn list)
    ~f:(fun (min, max) el -> smaller ~compare min el, larger ~compare max el)
;;

let append_some x list = Option.value_map x ~default:list ~f:(fun x -> list @ [x])
let option_trying f x = Option.try_with (fun () -> f x)

let touch_start_and_end (event : Dom_html.touchEvent Js.t) =
  let open Option.Let_syntax in
  (* touchend is fired as soon as a touch that *started* on this
     element ends. So we need to find the element that the touch is
     currently over, which might be some random element anywhere on
     the page, or a hex from a different board entirely. So we verify
     that it's a reasonable drag between hexes by checking the
     sibling relationship. *)
  let%bind touch = event##.changedTouches##item 0 |> Js.Opt.to_option in
  let get_location (element : #Dom.element Js.t) =
    element##getAttribute (Js.string "data-location")
    |> Js.Opt.to_option
    >>| Js.to_string
    >>= option_trying Location.of_string
  in
  let%bind end_element =
    Dom_html.document##elementFromPoint touch##.clientX touch##.clientY
    |> Js.Opt.to_option
  in
  let%bind start_element = event##.currentTarget |> Js.Opt.to_option in
  let%bind start_parent = start_element##.parentElement |> Js.Opt.to_option in
  let%bind () =
    Option.some_if (start_parent##contains (end_element :> Dom.node Js.t)) ()
  in
  let%bind start_location = get_location start_element in
  let%bind end_location = get_location end_element in
  return (start_location, end_location)
;;

let render_state state ~inject =
  let open Vdom in
  let {Board_state.dimensions; rotation; annotations; stones; disabled} = state in
  let rotation = Option.value rotation ~default:default_rotation in
  let board_transform =
    match rotation with
    | Rotated ->
      Transform.Rotation (-30)
    | Flat ->
      Transform.Identity
  in
  let locations =
    let open List.Let_syntax in
    let%bind row = List.init dimensions.height ~f:Fn.id in
    let%bind col = List.init dimensions.width ~f:Fn.id in
    let location = {Location.row; col} in
    if Location.Set.mem disabled location then [] else [location]
  in
  let location_set = Location.Set.of_list locations in
  let valid_edges =
    if Set.is_empty disabled
    then Edge.Set.of_list Edge.all
    else Edge.Set.singleton Bottom
  in
  let edge_decorations =
    List.map locations ~f:Location.neighbors
    |> Location.Set.union_list
    |> Fn.flip Location.Set.diff location_set
    |> Set.to_list
    |> List.filter_map ~f:(fun location ->
           let open Option.Let_syntax in
           let%bind edge = Edge.of_location dimensions location in
           let%bind () = Option.some_if (Edge.Set.mem valid_edges edge) () in
           let color = Edge.color edge in
           let%bind edge_hexes =
             testing
               (fun x -> List.length x = 2)
               (Set.inter location_set (Location.neighbors location) |> Set.to_list)
           in
           let directions =
             List.map edge_hexes ~f:(Location.direction_between_exn location)
           in
           let corners =
             List.concat_map directions ~f:Corner.of_direction
             |> List.dedup_and_sort ~compare:[%compare: Corner.t]
             |> List.map ~f:(point_at_corner ~radius:(0.9 *. radius))
           in
           Svg.polygon
             corners
             [ Attr_.transform (Translate (position location))
             ; Attr.classes ["edge-marker"; color_class color] ]
           |> return )
    |> Node.svg "g" ~key:"edge-decorations" []
  in
  let hexes =
    List.map locations ~f:(fun location ->
        get_hex
          location
          [ Attr.class_ "hex"
          ; Attr.create "data-location" (Location.to_string location)
          ; Attr.on "touchmove" (fun _ -> Event.Prevent_default)
          ; Attr.on "touchstart" (fun _ -> inject (Action.Start_annotation location))
          ; Attr.on_mousedown (fun _ -> inject (Action.Start_annotation location))
          ; Attr_.on_touchend (fun event ->
                match touch_start_and_end event with
                | Some (start, end_) ->
                  inject (Action.Annotation_between (start, end_))
                | None ->
                  Event.Ignore )
          ; Attr.on_mouseup (fun _ -> inject (Action.End_annotation location)) ] )
    |> Node.svg "g" ~key:"hexes" []
  in
  let stones =
    List.map stones ~f:(fun (color, location) ->
        Svg.circle
          (position location)
          (0.7 *. apothem)
          [Attr.classes ["stone"; color_class color]] )
    |> Node.svg "g" ~key:"stones" [Attr.class_ "stones"]
  in
  let annotations =
    Node.svg
      "g"
      ~key:"annotations"
      [Attr.class_ "annotations"]
      (List.map annotations ~f:render_annotation)
  in
  let labels =
    (if render_labels
    then
      List.map locations ~f:(fun location ->
          Node.svg
            "g"
            ~key:(Location.to_string location)
            [ Attr_.transform (Translate (position location))
            ; Attr.class_ "label-container" ]
            [ Svg.text
                (Location.to_string location)
                [Attr.class_ "label"; Attr_.transform (Transform.inverse board_transform)]
            ] )
    else [])
    |> Node.svg "g" ~key:"labels" [Attr.class_ "labels"]
  in
  let board =
    Node.svg
      "g"
      [Attr.class_ "board"; Attr_.transform board_transform]
      [edge_decorations; hexes; stones; annotations; labels]
  in
  let view_box =
    match rotation with
    | Flat ->
      let positions = List.map locations ~f:position in
      let left, right =
        List.map positions ~f:Point.x |> min_and_max_elt_exn ~compare:Float.compare
      in
      let top, bottom =
        List.map positions ~f:Point.y |> min_and_max_elt_exn ~compare:Float.compare
      in
      Rect.create ~left ~right ~top ~bottom
      |> Rect.pad ~horizontal:apothem ~vertical:radius
    | Rotated ->
      { Rect.origin = {Point.x = -.radius; y = -.apothem *. float dimensions.height}
      ; size =
          { Size.width =
              (spacing *. float ((dimensions.height - 1) * 2)) +. (2.0 *. radius)
          ; height = apothem *. float (dimensions.height * 2) } }
  in
  let view_box =
    Rect.pad
      view_box
      ~horizontal:0.25
      ~vertical:
        (match rotation with
        | Rotated ->
          0.25
        | Flat ->
          0.2)
  in
  let max_height = view_box.size.height *. 60.0 in
  Node.svg
    "svg"
    [ Attr_.view_box view_box
    ; Vdom.Attr.style ["max-height", strf max_height ^ "px"]
    ; Attr.create "preserveAspectRatio" "xMidYMid meet"
      (* prevents double-clicking or dragging outside the frame from selecting text *)
    ; Attr.on_mousedown (const Event.Prevent_default) ]
    [board]
;;

module Interaction = struct
  type t =
    | Toggle_annotation
    | Toggle_stone
  [@@deriving sexp_of, compare]

  let next = function
    | Toggle_annotation ->
      Toggle_stone
    | Toggle_stone ->
      Toggle_annotation
  ;;
end

module Model = struct
  type t =
    { states : Board_state.t Array.t
    ; state_index : int
    ; annotation_start : Location.t option
    ; interaction : Interaction.t }
  [@@deriving sexp_of, fields, compare]

  let create states =
    { states = Array.of_list states
    ; state_index = 0
    ; annotation_start = None
    ; interaction = Toggle_annotation }
  ;;

  let cutoff t1 t2 = compare t1 t2 = 0
  let state_count t = Array.length t.states

  let change_state t delta =
    { t with
      state_index = Int.clamp_exn (t.state_index + delta) ~min:0 ~max:(state_count t - 1)
    }
  ;;
end

let cons_some opt list = Option.value_map opt ~default:list ~f:(fun x -> x :: list)

let next_annotation location : Annotation.t option -> Annotation.t option = function
  | None ->
    Some (Dot location)
  | Some (Dot loc) ->
    Some (Star loc)
  | Some (Star _) ->
    None
  | Some (Line _ | Bridge _) ->
    failwith "no"
;;

let annotation_at_point (board_state : Board_state.t) location =
  List.find board_state.annotations ~f:(function
      | Dot loc ->
        Location.equal loc location
      | Star loc ->
        Location.equal loc location
      | Bridge _ ->
        false
      | Line _ ->
        false )
;;

let set_annotation_at_point (board_state : Board_state.t) location annotation =
  { board_state with
    annotations =
      List.filter board_state.annotations ~f:(function
          | Dot loc ->
            not (Location.equal loc location)
          | Star loc ->
            not (Location.equal loc location)
          | Bridge _ ->
            true
          | Line _ ->
            true )
      |> cons_some annotation }
;;

let next_stone : Color.t option -> Color.t option = function
  | None ->
    Some Black
  | Some Black ->
    Some White
  | Some White ->
    None
;;

let stone_at_point (board_state : Board_state.t) location =
  List.find_map board_state.stones ~f:(function
      | color, loc
        when Location.equal loc location ->
        Some color
      | _ ->
        None )
;;

let set_stone_at_point (board_state : Board_state.t) (location : Location.t) color =
  { board_state with
    stones =
      board_state.stones
      |> List.filter ~f:(fun (_, loc) -> not (Location.equal loc location))
      |> cons_some (Option.map color ~f:(fun color -> color, location)) }
;;

let cycle_annotation_at_point location board_state =
  set_annotation_at_point
    board_state
    location
    (annotation_at_point board_state location |> next_annotation location)
;;

let cycle_stone_at_point location board_state =
  set_stone_at_point
    board_state
    location
    (stone_at_point board_state location |> next_stone)
;;

let change_board_state (model : Model.t) ~f =
  (* TODO: get a better immutable vector structure *)
  let new_board_states = Array.copy model.states in
  Array.replace new_board_states model.state_index ~f;
  {model with states = new_board_states}
;;

let apply_annotation_between (model : Model.t) start_location end_location =
  if Location.( = ) start_location end_location
  then
    match model.interaction with
    | Toggle_annotation ->
      change_board_state model ~f:(cycle_annotation_at_point start_location)
    | Toggle_stone ->
      change_board_state model ~f:(cycle_stone_at_point start_location)
  else
    let new_annotation : Annotation.t =
      if (not (Location.adjacent start_location end_location))
         && List.length (shared_neighbors start_location end_location) = 2
      then Bridge (start_location, end_location)
      else Line (start_location, end_location)
    in
    change_board_state model ~f:(fun board_state ->
        let annotations =
          if List.mem
               board_state.annotations
               new_annotation
               ~equal:[%compare.equal: Annotation.t]
          then
            List.filter
              board_state.annotations
              ~f:(Fn.non ([%compare.equal: Annotation.t] new_annotation))
          else new_annotation :: board_state.annotations
        in
        {board_state with annotations} )
;;

let apply_action model action _ ~schedule_action:_ =
  match (action : Action.t) with
  | Next_state ->
    Model.change_state model 1
  | Prev_state ->
    Model.change_state model (-1)
  | Start_annotation location ->
    {model with annotation_start = Some location}
  | Toggle_interaction ->
    {model with interaction = Interaction.next model.interaction}
  | Annotation_between (start_location, end_location) ->
    apply_annotation_between model start_location end_location
  | End_annotation end_location ->
    (match model.annotation_start with
    | Some start_location ->
      { (apply_annotation_between model start_location end_location) with
        annotation_start = None }
    | None ->
      model)
;;

let on_startup ~schedule_action:_ _ = Async_kernel.return ()

let view (m : Model.t Incr.t) ~inject =
  let open Incr.Let_syntax in
  let open Vdom in
  let state_count = m >>| Model.state_count in
  let page_text =
    let%map state_index = m >>| Model.state_index
    and state_count = state_count in
    sprintf "%d / %d" (state_index + 1) state_count
  in
  let page_indicator =
    let%map page_text = page_text in
    Node.span [Attr.class_ "page-indicator"] [Node.text page_text]
  in
  let state =
    let%map state_index = m >>| Model.state_index
    and states = m >>| Model.states in
    states.(state_index)
  in
  let prev_state_button =
    mobile_friendly_button "←" Action.Prev_state [Attr.class_ "prev-state"] ~inject
  in
  let next_state_button =
    mobile_friendly_button "→" Action.Next_state [Attr.class_ "next-state"] ~inject
  in
  let toggle_interaction_button =
    let%map interaction = m >>| Model.interaction in
    let text =
      match interaction with
      | Toggle_annotation ->
        "Annotation mode"
      | Toggle_stone ->
        "Stone placement mode"
    in
    Node.div
      [Attr.class_ "toolbar"]
      [mobile_friendly_button ~inject text Action.Toggle_interaction []]
  in
  let debug_sexp =
    if render_sexps
    then
      let%map sexp = state >>| [%sexp_of: Board_state.t] in
      Some
        (Node.textarea [Attr.class_ "sexp"] [Node.text (Sexp_pretty.sexp_to_string sexp)])
    else return None
  in
  let svg = state >>| render_state ~inject in
  let%map page_indicator = page_indicator
  and svg = svg
  and debug_sexp = debug_sexp
  and toggle_interaction_button = toggle_interaction_button
  and state_count = state_count in
  let paging_controls =
    Option.some_if
      (state_count > 1)
      (Node.div
         [Attr.class_ "paging-controls"]
         [prev_state_button; page_indicator; next_state_button])
  in
  Node.div
    []
    (List.filter_opt
       [Some toggle_interaction_button; Some svg; paging_controls; debug_sexp])
;;

let create model ~old_model:_ ~inject =
  let open Incr.Let_syntax in
  let%map apply_action =
    let%map model = model in
    apply_action model
  and view = view model ~inject
  and model = model in
  Component.create ~apply_action model view
;;
