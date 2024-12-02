import gleam/int
import gleam/list
import gleam/string
import tote/bag

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.split(on: "\n")
  |> list.map(string.split(_, on: "   "))
  |> list.fold(from: #([], []), with: fn(acc, v) {
    let assert [l, r] = v
    let assert Ok(l) = int.parse(l)
    let assert Ok(r) = int.parse(r)
    let #(ll, lr) = acc
    #([l, ..ll], [r, ..lr])
  })
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  let #(l1, l2) = input
  let l1 = list.sort(l1, by: int.compare)
  let l2 = list.sort(l2, by: int.compare)

  fold2(l1, l2, from: 0, with: fn(e1, e2, acc) {
    int.absolute_value(e1 - e2) + acc
  })
}

pub fn pt_2(input: #(List(Int), List(Int))) -> Int {
  let #(l1, l2) = input
  let l2 = bag.from_list(l2)
  list.fold(over: l1, from: 0, with: fn(acc, e) {
    e * bag.copies(in: l2, of: e) + acc
  })
}

fn fold2(l1: List(a), l2: List(b), from acc: c, with fun: fn(a, b, c) -> c) -> c {
  case l1, l2 {
    [], _ | _, [] -> acc
    [hd1, ..tl1], [hd2, ..tl2] -> fold2(tl1, tl2, fun(hd1, hd2, acc), fun)
  }
}
