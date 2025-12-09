import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Coordinates =
  #(Int, Int)

pub fn parse(input: String) -> List(Coordinates) {
  string.split(input, "\n")
  |> list.map(string.split_once(_, ","))
  |> list.filter_map(fn(v) {
    use v <- result.try(v)
    use v1 <- result.try(int.parse(v.0))
    use v2 <- result.try(int.parse(v.1))
    Ok(#(v1, v2))
  })
}

pub fn pt_1(input: List(Coordinates)) {
  list.combination_pairs(input)
  |> list.map(fn(pair) {
    let #(c1, c2) = pair
    { 1 + int.absolute_value(c1.0 - c2.0) }
    * { 1 + int.absolute_value(c1.1 - c2.1) }
  })
  |> list.sort(int.compare)
  |> list.reverse()
  |> list.first()
  |> result.lazy_unwrap(fn() { panic })
}

pub fn pt_2(input: List(Coordinates)) {
  todo
}
