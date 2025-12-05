import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Ingredient =
  Int

pub type Range {
  Range(start: Int, end: Int)
}

pub fn parse(input: String) -> #(List(Range), Set(Ingredient)) {
  let assert Ok(#(ranges, ingredients)) = string.split_once(input, "\n\n")
    as "There shuld be a double newline separating ranges of fresh ingredients and ingredients"
  let ranges =
    string.split(ranges, "\n")
    |> list.map(string.split_once(_, "-"))
    |> list.map(fn(e) {
      let assert Ok(#(start, end)) = e as "Ranges should be separated by a -"
      let assert Ok(start) = int.parse(start)
        as "Ranges should be composed by two integers"
      let assert Ok(end) = int.parse(end)
        as "Ranges should be composed by two integers"

      Range(start:, end:)
    })

  let ingredients =
    string.split(ingredients, "\n")
    |> list.filter_map(int.parse)
    |> set.from_list

  #(ranges, ingredients)
}

pub fn pt_1(input: #(List(Range), Set(Ingredient))) {
  let #(ranges, ingredients) = input
  set.filter(ingredients, fn(ingredient) {
    list.any(ranges, contains(_, ingredient))
  })
  |> set.size()
}

fn contains(range: Range, ingredient: Ingredient) {
  range.start <= ingredient && ingredient <= range.end
}

pub fn pt_2(input: #(List(Range), Set(Ingredient))) {
  input.0
  |> list.fold(set.new(), adjust_for_overlapping)
  |> set.to_list()
  |> list.map(fn(range) { range.end + 1 - range.start })
  |> list.fold(0, int.add)
}

fn adjust_for_overlapping(acc, current) {
  let overlapping =
    set.filter(acc, overlaps(current, _))
    |> set.to_list()

  case overlapping {
    [] -> set.insert(acc, current)
    [first, ..] -> {
      let full_range =
        list.fold([current, ..overlapping], first, fn(acc, v) {
          let start = int.min(acc.start, v.start)
          let end = int.max(acc.end, v.end)
          Range(start:, end:)
        })

      set.drop(acc, overlapping)
      |> set.insert(full_range)
    }
  }
}

fn overlaps(a: Range, b: Range) -> Bool {
  { a.start <= b.start && a.end >= b.start }
  // Inverse possitions
  || { b.start <= a.start && b.end >= a.start }
}
