import gleam/list
import gleam/set.{type Set}
import gleam/string

type Coords =
  #(Int, Int)

pub fn parse(input: String) -> Set(Coords) {
  string.split(input, on: "\n")
  |> list.map(string.to_graphemes)
  |> list.index_fold(set.new(), fn(acc, row, y_index) {
    list.index_fold(row, acc, fn(acc, cell, x_index) {
      case cell {
        "." -> acc
        "@" -> set.insert(acc, #(x_index, y_index))
        _ -> panic as { "unexpected character, " <> cell }
      }
    })
  })
}

pub fn pt_1(input: Set(Coords)) {
  accessible(input)
  |> set.size
}

fn accessible(input: Set(Coords)) -> Set(Coords) {
  set.filter(input, fn(element) {
    let #(x, y) = element
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
        set.contains(input, #(x + transform.0, y + transform.1))
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

pub fn pt_2(input: Set(Coords)) {
  let start_length = input |> set.size

  let end_length = filter_until_no_removable(input) |> set.size

  start_length - end_length
}

fn filter_until_no_removable(acc: Set(Coords)) -> Set(Coords) {
  case accessible(acc) |> set.to_list() {
    [] -> acc
    accessible -> filter_until_no_removable(set.drop(acc, accessible))
  }
}
