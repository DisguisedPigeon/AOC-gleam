import gleam/int
import gleam/list
import gleam/pair
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
  |> list.map(corners_to_rectangles)
  |> list.map(area)
  |> list.sort(fn(some, other) { int.compare(other, some) })
  |> list.first()
  |> result.lazy_unwrap(fn() { panic })
}

pub fn pt_2(input: List(Coordinates)) {
  let border: List(Rectangle) =
    list.window_by_2(input) |> list.map(corners_to_rectangles)
  list.combination_pairs(input)
  |> list.map(corners_to_rectangles)
  |> list.map(fn(rect) { #(area(rect), rect) })
  |> list.sort(fn(some, other) {
    let #(some, _) = some
    let #(other, _) = other

    int.compare(other, some)
  })
  |> list.find(fn(item) {
    let #(_area, rectangle) = item
    !list.any(border, touches(_, rectangle))
  })
  |> result.lazy_unwrap(fn() { panic })
  |> pair.first
}

fn touches(border: Rectangle, rectangle: Rectangle) -> Bool {
  border.left < rectangle.right
  && border.right > rectangle.left
  && border.bot < rectangle.top
  && border.top > rectangle.bot
}

fn area(rectangle: Rectangle) {
  { rectangle.right - rectangle.left + 1 }
  * { rectangle.top - rectangle.bot + 1 }
}

fn corners_to_rectangles(corners: #(#(Int, Int), #(Int, Int))) -> Rectangle {
  let #(start, end) = corners

  Rectangle(
    top: int.max(start.1, end.1),
    bot: int.min(start.1, end.1),
    left: int.min(start.0, end.0),
    right: int.max(start.0, end.0),
  )
}

type Rectangle {
  Rectangle(top: Int, bot: Int, left: Int, right: Int)
}
