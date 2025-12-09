import gleam/dict
import gleam/list
import gleam/option
import gleam/set.{type Set}
import gleam/string

pub type Grid {
  Grid(source: Int, splitters: List(Set(Int)))
}

pub fn parse(input: String) -> Grid {
  let rows = string.split(input, "\n")
  let grid = list.map(rows, string.to_graphemes)

  let assert [source_row, ..splitters] = grid

  let assert Ok(source) =
    list.fold(source_row, Error(0), fn(acc, char) {
      case acc, char {
        Ok(_), _ -> acc
        Error(n), "S" -> Ok(n)
        Error(n), "." -> Error(n + 1)
        Error(_), _ -> panic
      }
    })

  let splitters =
    list.fold(splitters, [], fn(acc, row) {
      let row =
        list.index_fold(row, set.new(), fn(acc, c, index) {
          case c {
            "^" -> set.insert(acc, index)
            "." -> acc
            _ -> panic
          }
        })

      case set.is_empty(row) {
        True -> acc
        False -> [row, ..acc]
      }
    })
    |> list.reverse

  Grid(source:, splitters:)
}

pub fn pt_1(input: Grid) {
  let #(_heads, splits) =
    list.fold(
      input.splitters,
      #(set.from_list([input.source]), 0),
      fn(acc, row) {
        set.fold(acc.0, #(set.new(), acc.1), fn(acc, head) {
          case set.contains(row, head) {
            True -> #(
              set.insert(acc.0, head + 1) |> set.insert(head - 1),
              acc.1 + 1,
            )
            False -> #(set.insert(acc.0, head), acc.1)
          }
        })
      },
    )

  splits
}

pub fn pt_2(input: Grid) {
  list.fold(input.splitters, dict.from_list([#(input.source, 1)]), fn(acc, row) {
    set.fold(row, acc, fn(acc, split) {
      case dict.get(acc, split) {
        Ok(prev) -> {
          dict.delete(acc, split)
          |> dict.upsert(split - 1, fn(old) {
            case old {
              option.None -> prev
              option.Some(old) -> old + prev
            }
          })
          |> dict.upsert(split + 1, fn(old) {
            case old {
              option.None -> prev
              option.Some(old) -> old + prev
            }
          })
        }

        Error(Nil) -> acc
      }
    })
  })
  |> dict.fold(0, fn(acc, _k, v) { acc + v })
}
