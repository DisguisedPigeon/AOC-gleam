import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(#(Int, List(Int))) {
  string.split(input, "\n")
  |> list.filter_map(string.split_once(_, ":"))
  |> list.map(fn(e) {
    let assert Ok(result) = int.parse(e.0)
    let operands = string.split(e.1, " ") |> list.filter_map(int.parse)
    #(result, operands)
  })
}

pub fn pt_1(input: List(#(Int, List(Int)))) -> Int {
  list.fold(input, [], fn(acc, v) { try_operations(acc, v, [Sum, Prod]) })
  |> int.sum
}

fn try_operations(
  valid_results: List(Int),
  equation: #(Int, List(Int)),
  operations: List(Operations),
) -> List(Int) {
  let #(result, operands) = equation
  case validate(result, operands, 0, operations) {
    True -> [result, ..valid_results]
    False -> valid_results
  }
}

pub type Operations {
  Sum
  Prod
  Concat
}

fn validate(
  result: Int,
  operands: List(Int),
  acc: Int,
  operations: List(Operations),
) -> Bool {
  case operands {
    [] if result == acc -> True
    [] -> False
    [hd, ..tl] ->
      list.map(operations, fn(op) {
        validate(result, tl, operation(acc, op, hd), operations)
      })
      |> list.reduce(bool.or)
      |> result.unwrap(False)
  }
}

fn operation(a: Int, op: Operations, b: Int) -> Int {
  case op {
    Prod -> a * b
    Sum -> a + b
    Concat ->
      { int.to_string(a) <> int.to_string(b) }
      |> int.parse
      |> result.unwrap(-1)
  }
}

pub fn pt_2(input: List(#(Int, List(Int)))) -> Int {
  list.fold(input, [], fn(acc, v) {
    try_operations(acc, v, [Sum, Prod, Concat])
  })
  |> int.sum
}
