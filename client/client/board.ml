open! Core_kernel
open Incr_dom
open! Import

let render_sexps = false

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
end

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

let point_at_corner radius corner =
  let angle = (float corner +. 0.5) *. Float.pi *. 2.0 /. 6.0 in
  {Point.x = Float.cos angle *. radius; y = Float.sin angle *. radius}
;;

let all_corners = [0; 1; 2; 3; 4; 5]

let position (location : Location.t) =
  { Point.x = (float (location.col * 2) *. apothem) +. (apothem *. float location.row)
  ; y = spacing *. float location.row }
;;

let get_hex =
  let points = List.map all_corners ~f:(point_at_corner (radius *. 0.7)) in
  fun location ~classes ->
    Svg.polygon
      points
      [Attr_.transform (Translate (position location)); Vdom.Attr.classes classes]
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
          0.75
          (position span)
          (position (Location.in_direction span (Direction.inverse span_direction)))
      in
      let control2 =
        Point.average
          0.75
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
  let edge_pieces =
    Set.filter location_set ~f:(fun location ->
        let actual_neighbors = Set.inter (Location.neighbors location) location_set in
        Set.length actual_neighbors < 6 )
  in
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
           let bias = 0.55 in
           let center =
             (bias, location)
             :: List.map edge_hexes ~f:(fun edge_hex -> (1.0 -. bias) *. 0.5, edge_hex)
             |> List.map ~f:(fun (weight, location) ->
                    Point.( * ) weight (position location) )
             |> List.fold ~init:Point.zero ~f:Point.( + )
           in
           return
             (Svg.circle
                center
                (0.15 *. apothem)
                [Attr.classes ["edge-marker"; color_class color]]) )
  in
  let border =
    let points = edge_pieces |> Location.sort_border |> List.map ~f:position in
    Svg.polygon points [Attr.class_ "border"]
  in
  let hexes = List.map locations ~f:(get_hex ~classes:["hex"]) in
  let stones =
    List.map stones ~f:(fun (color, location) ->
        Svg.circle
          (position location)
          (0.7 *. apothem)
          [Attr.classes ["stone"; color_class color]] )
  in
  let annotations = List.map annotations ~f:render_annotation in
  let labels =
    List.map locations ~f:(fun location ->
        let label_hit_detector =
          Svg.circle
            Point.zero
            apothem
            [ Attr.class_ "hit-detector"
            ; Attr.on_mousedown (fun _ -> inject (Action.Start_annotation location))
            ; Attr.on_mouseup (fun _ -> inject (Action.End_annotation location)) ]
        in
        let label =
          Svg.text
            (Location.to_string location)
            [Attr.class_ "label"; Attr_.transform (Transform.inverse board_transform)]
        in
        Node.svg
          "g"
          ~key:(Location.to_string location)
          [Attr_.transform (Translate (position location)); Attr.class_ "label-container"]
          [label_hit_detector; label] )
  in
  let board =
    Node.svg
      "g"
      [Attr.class_ "board"; Attr_.transform board_transform]
      (List.concat [[border]; edge_decorations; hexes; stones; annotations; labels])
  in
  let view_box =
    match rotation with
    | Flat ->
      { Rect.origin = {Point.x = -.apothem; y = -.radius}
      ; size =
          { Size.width =
              (apothem *. float (2 * dimensions.width))
              +. (apothem *. float (dimensions.height - 1))
          ; height = (spacing *. float (dimensions.height - 1)) +. (2.0 *. radius) } }
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
      0.25
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
    ; Attr.create "preserveAspectRatio" "xMidYMid meet" ]
    [board]
;;

module Model = struct
  type t =
    { states : Board_state.t Array.t
    ; state_index : int
    ; annotation_start : Location.t option }
  [@@deriving sexp_of, fields, compare]

  let create states =
    {states = Array.of_list states; state_index = 0; annotation_start = None}
  ;;

  let cutoff t1 t2 = compare t1 t2 = 0
  let state_count t = Array.length t.states

  let change_state t delta =
    let state_count = state_count t in
    {t with state_index = (t.state_index + delta + state_count) % state_count}
  ;;
end

let apply_action model action _ ~schedule_action:_ =
  match (action : Action.t) with
  | Next_state ->
    Model.change_state model 1
  | Prev_state ->
    Model.change_state model (-1)
  | Start_annotation location ->
    {model with annotation_start = Some location}
  | End_annotation end_location ->
    (match model.annotation_start with
    | Some start_location ->
      let new_annotation : Annotation.t =
        if Location.( = ) start_location end_location
        then Dot start_location
        else if (not (Location.adjacent start_location end_location))
                && List.length (shared_neighbors start_location end_location) = 2
        then Bridge (start_location, end_location)
        else Line (start_location, end_location)
      in
      (* TODO: get a better immutable vector structure *)
      let new_board_states = Array.copy model.states in
      Array.replace new_board_states model.state_index ~f:(fun board_state ->
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
          {board_state with annotations} );
      {model with states = new_board_states; annotation_start = None}
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
  let on_click action = Attr.on_click (fun _ -> inject action) in
  let prev_state_button =
    Node.button [on_click Action.Prev_state; Attr.class_ "prev-state"] [Node.text "←"]
  in
  let next_state_button =
    Node.button [on_click Action.Next_state; Attr.class_ "next-state"] [Node.text "→"]
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
  and state_count = state_count in
  let paging_controls =
    Option.some_if
      (state_count > 1)
      (Node.div
         [Attr.class_ "paging-controls"]
         [prev_state_button; page_indicator; next_state_button])
  in
  Node.div [] (List.filter_opt [Some svg; paging_controls; debug_sexp])
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
