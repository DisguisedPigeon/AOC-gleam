import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type Region {
  Region(width: Int, height: Int, required_shapes: Dict(Int, Int))
}

pub type Input {
  Input(shapes: Dict(Int, Set(Coord)), regions: List(Region))
}

pub fn parse(input: String) -> Input {
  let assert [regions, ..shapes] = string.split(input, "\n\n") |> list.reverse

  let shapes =
    list.reverse(shapes)
    |> list.map(fn(shape) {
      let assert [index, ..shape] = string.split(shape, "\n")
      let assert Ok(index) = string.drop_end(index, 1) |> int.parse()

      let shape =
        list.index_fold(shape, set.new(), fn(acc, line, j) {
          string.to_graphemes(line)
          |> list.index_fold(acc, fn(acc, char, i) {
            case char {
              "#" -> set.insert(acc, Coord(x: i, y: j))
              "." -> acc
              _ -> panic
            }
          })
        })

      #(index, shape)
    })
    |> dict.from_list()

  let regions =
    string.split(regions, "\n")
    |> list.filter_map(string.split_once(_, ":"))
    |> list.map(fn(region) {
      let #(size, amounts) = region

      let #(width, height) = parse_size(size)
      let required_shapes =
        string.trim(amounts)
        |> string.split(" ")
        |> list.index_map(fn(e, i) {
          let assert Ok(amount) = int.parse(e)
          #(i, amount)
        })
        |> dict.from_list

      Region(width:, height:, required_shapes:)
    })

  Input(shapes, regions)
}

fn parse_size(size: String) -> #(Int, Int) {
  let assert Ok(#(w, h)) = string.split_once(size, "x")
  let assert #(Ok(w), Ok(h)) = #(int.parse(w), int.parse(h))

  #(w, h)
}

pub fn pt_1(input: Input) -> Int {
  size_check(input.regions)
}

pub fn pt_2(_input: Input) -> Int {
  panic as "doesn't exist"
}

fn size_check(regions) {
  list.count(regions, fn(region) {
    let Region(width:, height:, required_shapes:) = region
    9 * { dict.values(required_shapes) |> int.sum } <= width * height
  })
}
