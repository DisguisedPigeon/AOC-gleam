import gleam/int
import gleam/list
import gleam/string

pub type Bank =
  List(Int)

pub fn parse(input: String) -> List(Bank) {
  string.split(input, on: "\n")
  |> list.map(string.to_graphemes)
  |> list.map(list.filter_map(_, int.parse))
}

pub fn pt_1(input: List(Bank)) {
  list.map(input, max_joltage_n_cells(_, 2))
  |> int.sum()
}

type Accumulator {
  Accumulator(digit: Int, rest: Bank)
}

pub fn pt_2(input: List(Bank)) -> Int {
  // // Infinite memory solution (too many combinations >_<)
  // list.map(input, max_joltage_n_cells(_, 12))
  // |> int.sum()

  fast_joltage(input, 12)
}

fn fast_joltage(banks: List(Bank), number_of_chosen_cells: Int) -> Int {
  list.fold(banks, 0, fn(acc, rest) {
    let Accumulator(n, _rest) =
      // Iterator, from number - 1 to 0
      list.range(number_of_chosen_cells - 1, 0)
      |> list.fold(Accumulator(0, rest), find_biggest)

    acc + n
  })
}

// This function creates a window of possible values, chooses the biggest possible and removes every possible digit that led up to it
fn find_biggest(acc: Accumulator, iterator: Int) -> Accumulator {
  let Accumulator(digit:, rest:) = acc
  let assert Ok(#(max, location)) =
    // Reverse the list
    list.reverse(rest)
    // Drop from the back until we keep the candidates to next most significant digit
    |> list.drop(iterator)
    // Return to default order
    |> list.reverse()
    // Add locations, indexed to 0
    |> list.index_map(fn(item, index) { #(item, index) })
    // Get the biggest candidate
    |> list.max(fn(a, b) { int.compare(a.0, b.0) })

  // Add the digit to the accumulator
  //                            Drop all values preceding the chosen one.
  Accumulator(10 * digit + max, list.drop(rest, location + 1))
}

fn max_joltage_n_cells(bank: Bank, n: Int) -> Int {
  list.combinations(bank, n)
  |> list.fold(-1, fn(acc, combination) {
    let current = from_digits(combination)

    case current > acc {
      True -> current
      False -> acc
    }
  })
}

fn from_digits(combination: List(Int)) -> Int {
  let assert Ok(l) =
    list.map(combination, int.to_string)
    |> string.concat
    |> int.parse

  l
}
