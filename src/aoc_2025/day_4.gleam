import gleam/dict.{type Dict}
import gleam/list
import gleam/string

type Coords =
  #(Int, Int)

type Cell =
  Nil

pub fn parse(input: String) -> Dict(Coords, Cell) {
  string.split(input, on: "\n")
  |> list.map(string.to_graphemes)
  |> list.index_fold(dict.new(), fn(acc, row, y_index) {
    list.index_fold(row, acc, fn(acc, cell, x_index) {
      case cell {
        "." -> acc
        "@" -> dict.insert(acc, #(x_index, y_index), Nil)
        _ -> panic as { "unexpected character, " <> cell }
      }
    })
  })
}

pub fn pt_1(input: Dict(Coords, Cell)) {
  accessible(input)
  |> dict.size
}

fn accessible(input: Dict(Coords, Cell)) -> Dict(Coords, Cell) {
  dict.filter(input, fn(k, _) {
    let #(x, y) = k
    let to_check = [
      #(-1, -1),
      #(-1, 0),
      #(-1, 1),
      #(0, -1),
      #(0, 1),
      #(1, -1),
      #(1, 0),
      #(1, 1),
    ]

    let number_of_neighbors =
      list.map(to_check, fn(transform) {
        dict.has_key(input, #(x + transform.0, y + transform.1))
      })
      |> list.filter(fn(v) { v })
      |> list.length()

    case number_of_neighbors {
      // Counts origin cell
      0 | 1 | 2 | 3 -> True
      _ -> False
    }
  })
}

pub fn pt_2(input: Dict(Coords, Cell)) {
  let start_length = input |> dict.size

  let end_length = filter_until_no_removable(input) |> dict.size

  start_length - end_length
}

fn filter_until_no_removable(acc: Dict(Coords, Cell)) -> Dict(Coords, Cell) {
  case accessible(acc) |> dict.keys() {
    [] -> acc
    accessible -> filter_until_no_removable(dict.drop(acc, accessible))
  }
}
