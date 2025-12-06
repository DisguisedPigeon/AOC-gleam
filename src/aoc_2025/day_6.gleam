import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn parse_int_or_operation(acc: Instruction, str: String) -> Instruction {
  case str {
    "+" -> Instruction(Sum, [])
    "*" -> Instruction(Prod, [])
    " " -> acc
    "" -> acc
    n -> {
      let assert Ok(n) = int.parse(n)
      Instruction(..acc, values: [n, ..acc.values])
    }
  }
}

pub fn pt_1(input: String) {
  string.trim(input)
  |> string.split("\n")
  |> list.map(string.split(_, " "))
  |> list.map(list.filter(_, fn(v) { v != " " && v != "" }))
  |> list.transpose()
  |> list.map(list.reverse)
  |> list.map(fn(operation) {
    list.fold(operation, Instruction(Sum, []), parse_int_or_operation)
  })
  |> list.map(calc)
  |> int.sum
}

fn calc(instruction: Instruction) -> Int {
  case instruction.operation {
    Sum -> int.sum(instruction.values)
    Prod -> int.product(instruction.values)
  }
}

fn last_is_operator(l: List(String)) -> Bool {
  case list.reverse(l) {
    ["+", ..] | ["*", ..] -> True
    _ -> False
  }
}

pub type Operation {
  Sum
  Prod
}

pub type Instruction {
  Instruction(operation: Operation, values: List(Int))
}

pub fn pt_2(input: String) {
  string.split(input, "\n")
  |> list.map(string.to_graphemes)
  // Get the columns
  |> list.transpose()
  // Divide the list into [[column_with_operator], list_of_columns_with_no_operator, ...]
  |> list.chunk(last_is_operator)
  // Group them
  |> list.sized_chunk(2)
  // Get rid of the extra lists
  // [[operator, no operator, no operator, ...], ...]
  |> list.map(list.flatten)
  // Turn them into instructions
  |> list.map(list.fold(_, Instruction(Sum, []), parse_p2))
  |> list.map(calc)
  |> int.sum
}

fn parse_p2(acc: Instruction, column: List(String)) -> Instruction {
  case list.reverse(column) {
    // A column can have an operator or no operator
    ["*", ..] -> Instruction(Prod, [int_from_digits(column)])
    ["+", ..] -> Instruction(Sum, [int_from_digits(column)])
    _ -> {
      // It may be empty, problematic for Prod
      case list.all(column, fn(v) { " " == v }) {
        True -> acc
        // In other cases, parse the int from the column and add it to the list
        False ->
          Instruction(..acc, values: [int_from_digits(column), ..acc.values])
      }
    }
  }
}

fn int_from_digits(l: List(String)) -> Int {
  // This would ideally be a string.concat(l) |> int.parse, but we have to get rid of extra characters
  list.fold(l, 0, fn(acc, c) {
    case c {
      "" | " " | "+" | "*" -> acc
      _ ->
        acc
        * 10
        + result.lazy_unwrap(int.parse(c), fn() {
          panic as { "couldn't parse int " <> string.inspect(c) }
        })
    }
  })
}
