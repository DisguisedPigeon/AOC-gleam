import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Multiplication {
  Multiplication(n1: Int, n2: Int, enabled: Bool)
}

pub fn parse(input: String) -> List(String) {
  string.to_graphemes(input)
}

pub fn pt_1(memory: List(String)) -> Int {
  parse_memory(memory:, enabled: True, from: [])
  |> list.fold(from: 0, with: pt_1_reducer)
}

pub fn pt_2(memory: List(String)) -> Int {
  parse_memory(memory:, enabled: True, from: [])
  |> list.fold(from: 0, with: pt_2_reducer)
}

fn pt_1_reducer(acc: Int, multiplication: Multiplication) -> Int {
  acc + multiplication.n1 * multiplication.n2
}

fn pt_2_reducer(acc: Int, multiplication: Multiplication) -> Int {
  case multiplication.enabled {
    True -> acc + multiplication.n1 * multiplication.n2
    False -> acc
  }
}

fn parse_memory(
  memory memory: List(String),
  enabled enabled: Bool,
  from acc: List(Multiplication),
) {
  case memory {
    // do()
    ["d", "o", "(", ")", ..tl] ->
      parse_memory(memory: tl, enabled: True, from: acc)

    // don't()
    ["d", "o", "n", "'", "t", "(", ")", ..tl] ->
      parse_memory(memory: tl, enabled: False, from: acc)

    // mul(a, b)
    ["m", "u", "l", "(", ..tl] ->
      case parse_multiplication(tl, enabled) {
        Ok(#(mult, memory)) ->
          parse_memory(memory:, enabled:, from: [mult, ..acc])
        Error(_) -> parse_memory(memory: tl, enabled:, from: acc)
      }

    [] -> acc
    [_, ..tl] -> parse_memory(memory: tl, enabled:, from: acc)
  }
}

fn parse_multiplication(
  memory memory: List(String),
  enabled enabled: Bool,
) -> Result(#(Multiplication, List(String)), Nil) {
  use #(n1, memory) <- result.try(parse_num(memory:, acc: [], separator: ","))
  use #(n2, memory) <- result.try(parse_num(memory:, acc: [], separator: ")"))
  Ok(#(Multiplication(n1:, n2:, enabled:), memory))
}

fn parse_num(
  memory memory: List(String),
  acc acc: List(String),
  separator sep: String,
) -> Result(#(Int, List(String)), Nil) {
  case memory {
    ["0" as num, ..tl]
    | ["1" as num, ..tl]
    | ["2" as num, ..tl]
    | ["3" as num, ..tl]
    | ["4" as num, ..tl]
    | ["5" as num, ..tl]
    | ["6" as num, ..tl]
    | ["7" as num, ..tl]
    | ["8" as num, ..tl]
    | ["9" as num, ..tl] -> parse_num(tl, [num, ..acc], sep)

    [c, ..tl] if c == sep ->
      acc
      |> list.reverse
      |> string.concat
      |> int.parse
      |> result.map(fn(e) { #(e, tl) })

    [_, ..] -> Error(Nil)
    [] -> Error(Nil)
  }
}
