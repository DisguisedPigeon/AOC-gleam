import gleam/dict.{type Dict}
import gleam/list
import gleam/string

type Pair =
  #(Int, Int)

pub fn parse(input: String) -> Dict(Pair, String) {
  use dict, line, row <- list.index_fold(string.split(input, "\n"), dict.new())
  use dict, char, col <- list.index_fold(string.to_graphemes(line), dict)
  case char {
    "X" | "M" | "A" | "S" -> dict.insert(dict, #(row, col), char)
    _ -> dict
  }
}

pub fn pt_1(input: Dict(Pair, String)) -> Int {
  dict.fold(input, 0, fn(acc, coords, char) {
    case char {
      "X" -> acc + direction_check(coords, input)
      _ -> acc
    }
  })
}

fn direction_check(origin: Pair, data: Dict(Pair, String)) -> Int {
  let #(x, y) = origin
  list.fold(gen_directions(), 0, fn(acc, delta) {
    let #(dx, dy) = delta
    case
      dict.get(data, #(x + dx * 1, y + dy * 1)),
      dict.get(data, #(x + dx * 2, y + dy * 2)),
      dict.get(data, #(x + dx * 3, y + dy * 3))
    {
      Ok("M"), Ok("A"), Ok("S") -> acc + 1
      _, _, _ -> acc
    }
  })
}

fn gen_directions() -> List(#(Int, Int)) {
  [#(0, 1), #(0, -1), #(1, 1), #(-1, -1), #(1, 0), #(-1, 0), #(1, -1), #(-1, 1)]
}

pub fn pt_2(input: Dict(Pair, String)) {
  dict.fold(input, 0, fn(acc, coords, char) {
    case char {
      "A" -> acc + x_check(coords, input)
      _ -> acc
    }
  })
}

fn x_check(origin: Pair, data: Dict(Pair, String)) -> Int {
  let values =
    list.fold(gen_x(), [], fn(acc, delta) {
      let #(dx, dy) = delta
      case dict.get(data, #(origin.0 + dx, origin.1 + dy)) {
        Ok(v) if v == "M" || v == "S" -> [Ok(v), ..acc]
        Ok(v) -> [Error(v), ..acc]
        Error(_) -> acc
      }
    })

  case values {
    [Ok(a), Ok(b), Ok(c), Ok(d)] if a != c && b != d -> 1
    _ -> 0
  }
}

fn gen_x() -> List(#(Int, Int)) {
  [#(-1, -1), #(1, -1), #(1, 1), #(-1, 1)]
}
