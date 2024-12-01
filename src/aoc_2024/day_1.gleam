import gleam/int
import gleam/list
import gleam/string

fn parse_lists(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.split("\n")
  |> list.map(string.split(_, "   "))
  |> list.fold(#([], []), fn(acc, v) {
    let assert [l, r] = v
    let assert Ok(l) = int.parse(l)
    let assert Ok(r) = int.parse(r)
    let #(ll, lr) = acc
    #([l, ..ll], [r, ..lr])
  })
}

pub fn pt_1(input: String) {
  let #(l1, l2) = parse_lists(input)

  let l1 = list.sort(l1, int.compare)
  let l2 = list.sort(l2, int.compare)

  list.map2(l1, l2, fn(e1, e2) { int.absolute_value(e1 - e2) }) |> int.sum
}

pub fn pt_2(input: String) {
  let #(l1, l2) = parse_lists(input)
  l1
  |> list.map(fn(e) { list.count(l2, fn(v) { v == e }) * e })
  |> int.sum
}
