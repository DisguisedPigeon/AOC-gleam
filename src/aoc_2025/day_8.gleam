import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/set
import gleam/string

type Coordinates =
  #(Int, Int, Int)

pub fn parse(input: String) -> List(Coordinates) {
  string.split(input, "\n")
  |> list.map(fn(s) {
    let assert [v1, v2, v3] = string.split(s, ",")

    let assert Ok(v1) = int.parse(v1)
      as { "v1 (" <> v1 <> ") is not a valid int" }
    let assert Ok(v2) = int.parse(v2)
      as { "v2 (" <> v2 <> ") is not a valid int" }
    let assert Ok(v3) = int.parse(v3)
      as { "v3 (" <> v3 <> ") is not a valid int" }

    #(v1, v2, v3)
  })
}

pub fn pt_1(input: List(Coordinates)) {
  list.combination_pairs(input)
  |> map_keep(fn(v) { distance(v.0, v.1) })
  |> list.sort(fn(some, other) { float.compare(some.1, other.1) })
  |> list.map(pair.first)
  |> list.index_fold([], fn(nodes, pair, index) {
    case index {
      _ if index < 1000 ->
        case
          list.filter(nodes, fn(s) { set.contains(s, pair.0) }),
          list.filter(nodes, fn(s) { set.contains(s, pair.1) })
        {
          [s1], [s2] -> [
            set.union(s1, s2),
            ..list.filter(nodes, fn(set) { set != s1 && set != s2 })
          ]
          [s1], [] -> [
            set.insert(s1, pair.1),
            ..list.filter(nodes, fn(e) { e != s1 })
          ]
          [], [s2] -> [
            set.insert(s2, pair.0),
            ..list.filter(nodes, fn(e) { e != s2 })
          ]
          [], [] -> [set.from_list([pair.0, pair.1]), ..nodes]
          _, _ -> panic
        }

      _ ->
        case
          list.find(nodes, fn(s) { set.contains(s, pair.0) }),
          list.find(nodes, fn(s) { set.contains(s, pair.1) })
        {
          Error(Nil), Error(Nil) -> [
            set.from_list([pair.0]),
            set.from_list([pair.1]),
            ..nodes
          ]
          Error(Nil), Ok(_) -> [set.from_list([pair.0]), ..nodes]
          Ok(_), Error(Nil) -> [set.from_list([pair.1]), ..nodes]
          Ok(_), Ok(_) -> nodes
        }
    }
  })
  |> list.map(set.size)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> int.product
}

fn map_keep(input: List(a), with fun: fn(a) -> c) -> List(#(a, c)) {
  do_map_keep(input, fun, [])
}

fn do_map_keep(
  input: List(a),
  fun: fn(a) -> c,
  acc: List(#(a, c)),
) -> List(#(a, c)) {
  case input {
    [] -> list.reverse(acc)
    [first, ..rest] -> do_map_keep(rest, fun, [#(first, fun(first)), ..acc])
  }
}

fn distance(p1: Coordinates, p2: Coordinates) -> Float {
  let assert Ok(v1) = int.power(p2.0 - p1.0, 2.0)
  let assert Ok(v2) = int.power(p2.1 - p1.1, 2.0)
  let assert Ok(v3) = int.power(p2.2 - p1.2, 2.0)

  v1 +. v2 +. v3
}

pub fn pt_2(input: List(Coordinates)) {
  list.combination_pairs(input)
  |> map_keep(fn(v) { distance(v.0, v.1) })
  |> list.sort(fn(some, other) { float.compare(some.1, other.1) })
  |> list.map(pair.first)
  |> list.fold_until(#(#(#(-1, -1, -1), #(-1, -1, -1)), []), fn(acc, pair) {
    let assert #(#(#(-1, -1, -1), #(-1, -1, -1)), nodes) = acc
    let l = case
      list.filter(nodes, fn(s) { set.contains(s, pair.0) }),
      list.filter(nodes, fn(s) { set.contains(s, pair.1) })
    {
      [s1], [s2] -> [
        set.union(s1, s2),
        ..list.filter(nodes, fn(set) { set != s1 && set != s2 })
      ]
      [s1], [] -> [
        set.insert(s1, pair.1),
        ..list.filter(nodes, fn(e) { e != s1 })
      ]
      [], [s2] -> [
        set.insert(s2, pair.0),
        ..list.filter(nodes, fn(e) { e != s2 })
      ]
      [], [] -> [set.from_list([pair.0, pair.1]), ..nodes]
      _, _ -> panic
    }

    case l {
      [set] -> {
        case set.size(set) == list.length(input) {
          True -> list.Stop(#(pair, l))
          False -> list.Continue(#(#(#(-1, -1, -1), #(-1, -1, -1)), l))
        }
      }
      [_, ..] -> list.Continue(#(#(#(-1, -1, -1), #(-1, -1, -1)), l))
      [] -> panic
    }
  })
  |> pair.first
  |> fn(pair) {
    let #(v1, v2) = pair
    v1.0 * v2.0
  }
}
