import gleam/bool
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import glearray.{type Array}

type Direction {
  Top
  Bottom
  Left
  Right

  TopLeft
  TopRight
  BottomLeft
  BottomRight
}

type Vector {
  Vector(start: Direction, end: Direction)
}

type Coords =
  #(Int, Int)

pub fn parse(input: String) -> #(List(List(String)), Array(Array(String))) {
  let as_list =
    string.split(input, on: "\n")
    |> list.map(string.to_graphemes)
  let as_array = list.map(as_list, glearray.from_list(_)) |> glearray.from_list
  #(as_list, as_array)
}

pub fn pt_1(input: #(List(List(String)), Array(Array(String)))) {
  list.index_fold(input.0, 0, fn(acc, list, index) {
    i_loop(input.1, acc, list, index, "XMAS")
  })
}

fn i_loop(
  array: Array(Array(String)),
  acc: Int,
  line: List(String),
  i: Int,
  str: String,
) -> Int {
  list.index_fold(line, acc, fn(acc, char, j) {
    j_loop(array, acc, char, i, j, str)
  })
}

fn j_loop(
  array: Array(Array(String)),
  acc: Int,
  char: String,
  i: Int,
  j: Int,
  str: String,
) -> Int {
  let assert Ok(first) = string.first(str)
  case char {
    a if a == first -> count_str(array, i, j, str) + acc
    _ -> acc
  }
}

fn count_str(array: Array(Array(String)), x: Int, y: Int, str: String) -> Int {
  let str = string.to_graphemes(str) |> glearray.from_list()
  check_direction(Vector(Top, Bottom), array, x, y, str)
  + check_direction(Vector(Bottom, Top), array, x, y, str)
  + check_direction(Vector(Left, Right), array, x, y, str)
  + check_direction(Vector(Right, Left), array, x, y, str)
  + check_direction(Vector(TopLeft, BottomRight), array, x, y, str)
  + check_direction(Vector(BottomRight, TopLeft), array, x, y, str)
  + check_direction(Vector(BottomLeft, TopRight), array, x, y, str)
  + check_direction(Vector(TopRight, BottomLeft), array, x, y, str)
}

fn check_direction(
  vec: Vector,
  arr: Array(Array(String)),
  x: Int,
  y: Int,
  str: Array(String),
) -> Int {
  translate_vector(vec) |> check(arr, x, y, 0, str)
}

fn translate_vector(vector: Vector) -> Coords {
  case vector {
    Vector(Top, Bottom) -> #(1, 0)
    Vector(Bottom, Top) -> #(-1, 0)
    Vector(Left, Right) -> #(0, 1)
    Vector(Right, Left) -> #(0, -1)
    Vector(TopLeft, BottomRight) -> #(1, 1)
    Vector(BottomRight, TopLeft) -> #(-1, -1)
    Vector(BottomLeft, TopRight) -> #(-1, 1)
    Vector(TopRight, BottomLeft) -> #(1, -1)
    _ -> panic as "Invalid direction"
  }
}

fn check(
  dir: Coords,
  arr: Array(Array(String)),
  x: Int,
  y: Int,
  delta: Int,
  str: Array(String),
) -> Int {
  {
    use s <- result.try(glearray.get(str, delta))
    case glearray.get(arr, x + dir.0 * delta) {
      Ok(v) ->
        case glearray.get(v, y + dir.1 * delta), s {
          Ok(a), b if a == b -> Ok(check(dir, arr, x, y, delta + 1, str))
          Ok(_), _ -> Ok(0)
          Error(_), _ -> Ok(0)
        }

      Error(_) -> Ok(0)
    }
  }
  |> result.unwrap(1)
}

pub fn pt_2(
  input: #(List(List(String)), glearray.Array(glearray.Array(String))),
) {
  list.index_fold(input.0, 0, fn(acc, list, index) {
    i_loop_2(input.1, acc, list, index)
  })
}

fn i_loop_2(array, acc, line, i) {
  list.index_fold(line, acc, fn(acc, char, j) {
    j_loop_2(array, acc, char, i, j)
  })
}

fn j_loop_2(array, acc, char, i, j) -> Int {
  case char {
    a if a == "A" -> acc + count_xes(array, i, j)
    _ -> acc
  }
}

fn count_xes(array, x, y) {
  let a = test_for_position(array, x - 1, y - 1)
  let b = test_for_position(array, x + 1, y - 1)
  let c = test_for_position(array, x + 1, y + 1)
  let d = test_for_position(array, x - 1, y + 1)

  use <- continue_if_m_or_s(a)
  use <- continue_if_m_or_s(b)
  use <- continue_if_m_or_s(c)
  use <- continue_if_m_or_s(d)
  case Nil {
    _ if a != c && b != d -> 1
    _ -> 0
  }
}

fn continue_if_m_or_s(v, continue) {
  case v {
    "M" | "S" -> continue()
    _ -> 0
  }
}

fn test_for_position(array, c1, c2) {
  {
    use v <- result.try(glearray.get(array, c1))
    use v <- result.try(glearray.get(v, c2))

    case v {
      "M" | "S" -> Ok(v)
      _ -> Error(Nil)
    }
  }
  |> result.unwrap(".")
}
