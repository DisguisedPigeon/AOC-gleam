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
  list.fold(combination, 0, fn(acc, v) { acc * 10 + v })
}

pub fn pt_2(input: List(Bank)) -> Int {
  // // Infinite memory solution (too many combinations >_<)
  // list.map(input, max_joltage_n_cells(_, 12))
  // |> int.sum()

  fast_joltage(for: input, length: 12)
}

type Accumulator {
  Accumulator(digit: Int, rest: Bank)
}

fn fast_joltage(
  for banks: List(Bank),
  length number_of_chosen_cells: Int,
) -> Int {
  list.fold(over: banks, from: 0, with: fn(acc: Int, rest: List(Int)) -> Int {
    let Accumulator(n, _rest) =
      // This will be the minimum number of candidates we must have left for each choice
      list.range(from: number_of_chosen_cells - 1, to: 0)
      |> list.fold(from: Accumulator(0, rest), with: max_possible_joltage)

    acc + n
  })
}

fn max_possible_joltage(
  acc: Accumulator,
  max_candidates up_to: Int,
) -> Accumulator {
  let Accumulator(digit:, rest:) = acc
  let assert Ok(#(max, location)) =
    list.reverse(rest)
    |> list.drop(up_to:)
    |> list.reverse()
    |> list.index_map(fn(item, index) { #(item, index) })
    |> list.max(fn(a, b) { int.compare(a.0, b.0) })

  Accumulator(10 * digit + max, list.drop(rest, location + 1))
}
