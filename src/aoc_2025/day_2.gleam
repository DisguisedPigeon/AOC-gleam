import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

pub type Range {
  Range(start: Int, end: Int)
}

pub fn parse(input: String) -> List(Range) {
  string.split(input, on: ",")
  |> list.filter_map(string.split_once(_, on: "-"))
  |> list.filter_map(fn(item: #(String, String)) -> Result(Range, _) {
    let #(start, end) = item
    use start <- result.try(int.parse(start))
    use end <- result.try(int.parse(end))
    Ok(Range(start:, end:))
  })
}

pub fn pt_1(input: List(Range)) {
  // Takes in a range and returns a list of contained values
  let actualize_range = fn(range: Range) -> List(Int) {
    list.range(from: range.start, to: range.end)
  }

  list.map(input, with: actualize_range)
  |> list.flatten()
  |> list.map(int.to_string)
  |> list.filter_map(fn(value: String) -> Result(Int, Nil) {
    let length = string.length(value)
    let first_half = string.slice(value, 0, length / 2)
    let second_half = string.slice(value, length / 2, length)

    // (Stolen from past year) Clever way to filter and parse always valid integers on the same step
    case first_half == second_half {
      True -> int.parse(value)
      False -> Error(Nil)
    }
  })
  |> int.sum
}

pub fn pt_2(input: List(Range)) {
  list.map(input, fn(range) { list.range(from: range.start, to: range.end) })
  |> list.flatten
  |> list.map(int.to_string)
  |> list.filter_map(is_invalid_and_parse)
  |> int.sum
}

fn is_invalid_and_parse(value: String) -> Result(Int, Nil) {
  let upper_bound = string.length(value) / 2

  case is_invalid(value, starting_size: 1, upper_bound:) {
    True -> int.parse(value)
    False -> Error(Nil)
  }
}

fn is_invalid(
  value: String,
  starting_size segment_size: Int,
  upper_bound upper_bound: Int,
) -> Bool {
  use <- bool.guard(segment_size > upper_bound, return: False)

  let segments = break_string(value, segment_size:)
  use <- bool.guard(
    when: option.is_none(segments),
    return: is_invalid(value, segment_size + 1, upper_bound),
  )

  let assert option.Some(segments) = segments
    as "Can't be none, since it's checked above"

  let assert Ok(first) = list.first(segments)
    as "Empty string is checked on break_string"

  case
    list.all(segments, satisfying: fn(other: String) -> Bool { first == other })
  {
    // All segments are equal, the value is invalid
    True -> True
    False -> is_invalid(value, segment_size + 1, upper_bound)
  }
}

fn break_string(
  value: String,
  segment_size segment_size: Int,
) -> Option(List(String)) {
  let length = string.length(value)
  // If the string isn't divisible in segment_size segments, it can't be invalid with that size
  use <- bool.guard(length % segment_size != 0 && length != 0, option.None)

  case consume(value:, segment_size:, start: 0, upper_bound: length, acc: []) {
    [] -> panic as "Can't be"
    [_] -> option.None
    [_, ..] as v -> option.Some(v)
  }
}

fn consume(
  value value: String,
  segment_size length: Int,
  start at_index: Int,
  upper_bound max: Int,
  acc acc: List(String),
) -> List(String) {
  use <- bool.guard(at_index >= max, return: acc)
  consume(value, length, at_index + length, max, [
    string.slice(value, at_index:, length:),
    ..acc
  ])
}
