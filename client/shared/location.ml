open! Core_kernel

module T = struct
  type t =
    { row : int
    ; col : int }
  [@@deriving compare, bin_io, hash]

  let to_string {row; col} =
    sprintf "%c%d" (Char.of_int_exn (Char.to_int 'A' + col)) (row + 1)
  ;;

  let of_string str =
    let str = String.uppercase str in
    let col = Char.to_int str.[0] - Char.to_int 'A' in
    let row = int_of_string (String.drop_prefix str 1) - 1 in
    {row; col}
  ;;

  let t_of_sexp = function
    | Sexp.Atom str ->
      of_string str
    | _ ->
      failwith "invalid sexp"
  ;;

  let sexp_of_t t = Sexp.Atom (to_string t)
end

include T
include Comparable.Make (T)
include Hashable.Make (T)

let%expect_test _ =
  print_endline (to_string {row = 0; col = 0});
  [%expect "A1"];
  print_endline (to_string {row = 10; col = 4});
  [%expect "E11"]
;;

let of_tuple (row, col) = {row; col}

let direction_between t t' =
  let rd = t'.row - t.row in
  let cd = t'.col - t.col in
  match cd, rd with
  | 0, -1 ->
    Some Direction.W
  | 1, -1 ->
    Some Direction.E
  | -1, 0 ->
    Some Direction.A
  | 1, 0 ->
    Some Direction.D
  | 0, 1 ->
    Some Direction.X
  | -1, 1 ->
    Some Direction.Z
  | _ ->
    None
;;

let direction_between_exn t t' =
  Option.value_exn ~message:"not adjacent" (direction_between t t')
;;

let adjacent t t' = Option.is_some (direction_between t t')

let in_direction t direction =
  let row = t.row in
  let col = t.col in
  match direction with
  | Direction.W ->
    {row = row - 1; col}
  | Direction.E ->
    {row = row - 1; col = col + 1}
  | Direction.A ->
    {row; col = col - 1}
  | Direction.D ->
    {row; col = col + 1}
  | Direction.Z ->
    {row = row + 1; col = col - 1}
  | Direction.X ->
    {row = row + 1; col}
;;

let neighbors t = List.map ~f:(in_direction t) Direction.all |> Set.of_list

(** Requires that all hexes form a single loop. Returns the hexes, starting in
    an arbitrary place and moving in an arbitrary direction, such that each hex
    is adjacent to one another and the final hex is adjacent to the initial
    hex. *)
let sort_border border_hexes =
  let current_hex = ref (Set.min_elt_exn border_hexes) in
  let visited = Hash_set.of_list [!current_hex] in
  (* why is the API like this *)
  let module Hash_set = Base.Hash_set in
  let result = ref [!current_hex] in
  let neighbor_count hex = Set.length (Set.inter border_hexes (neighbors hex)) in
  while Int.( < ) (Hash_set.length visited) (Set.length border_hexes) do
    let possible_next_hexes =
      neighbors !current_hex
      |> Set.inter border_hexes
      |> Set.filter ~f:(Fn.non (Hash_set.mem visited))
      |> Set.to_list
    in
    let next_hex =
      match possible_next_hexes with
      | [only_option] ->
        only_option
      | [first_choice; second_choice] ->
        if adjacent first_choice second_choice
        then
          match neighbor_count first_choice, neighbor_count second_choice with
          | 3, 3 ->
            (* it's the very first iteration and we've started on the acute
               corner piece. Pick arbitrarily. *)
            first_choice
          | 2, 3 ->
            (* we're entering an acute corner from an edge -- we must pick the
               acute piece, which is the one with only two adjacent pieces *)
            first_choice
          | 3, 2 ->
            second_choice
          | a, b ->
            failwithf "unknown edge configuration A (%d, %d)" a b ()
        else (* this is the first iteration -- we choose on arbitrarily *)
          first_choice
      | [first_choice; second_choice; third_choice] ->
        (* this can only occur if the initial piece is adjacent to an acute
           corner -- pick the odd one out, for simplicity *)
        if adjacent first_choice second_choice
        then third_choice
        else if adjacent first_choice third_choice
        then second_choice
        else if adjacent second_choice third_choice
        then first_choice
        else
          failwithf
            !"unknown edge configuration B %{sexp: t list}"
            possible_next_hexes
            ()
      | _ ->
        failwithf !"unknown edge configuration C %{sexp: t list}" possible_next_hexes ()
    in
    Hash_set.strict_add_exn visited next_hex;
    result := next_hex :: !result;
    current_hex := next_hex
  done;
  !result
;;

let%expect_test "sort_border" =
  let test locations =
    let border_pieces = Set.of_list (List.map locations ~f:of_string) in
    sort_border border_pieces |> [%sexp_of: t list] |> print_s
  in
  test ["E4"; "F4"; "E6"; "D6"; "D5"; "F5"];
  [%expect {| (D5 D6 E6 F5 F4 E4) |}];
  test ["C1"; "D1"; "D2"; "D3"; "C3"; "B3"; "A3"; "B2"];
  [%expect {| (B2 A3 B3 C3 D3 D2 D1 C1) |}]
;;
