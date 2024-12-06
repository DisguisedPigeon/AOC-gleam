import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Direction {
  North
  East
  South
  West
}

pub type Size {
  Size(w: Int, h: Int)
}

pub type Coordinates =
  #(Int, Int)

pub type Guard {
  Guard(x: Int, y: Int, facing: Direction)
}

pub type Data {
  Data(guard: Guard, size: Size, boxes: Dict(Coordinates, String))
}

pub fn parse(input: String) -> Data {
  let grid =
    string.split(input, "\n")
    |> list.map(string.to_graphemes)

  {
    use acc, line, y <- list.index_fold(
      over: grid,
      from: Data(Guard(69, 69, North), Size(0, 0), dict.new()),
    )
    let data = {
      use acc, element, x <- list.index_fold(over: line, from: acc)
      case element {
        "^" ->
          Data(
            ..acc,
            guard: Guard(x:, y:, facing: North),
            size: Size(..acc.size, w: acc.size.w + 1),
          )
        ">" ->
          Data(
            ..acc,
            guard: Guard(x:, y:, facing: East),
            size: Size(..acc.size, w: acc.size.w + 1),
          )
        "v" ->
          Data(
            ..acc,
            guard: Guard(x:, y:, facing: South),
            size: Size(..acc.size, w: acc.size.w + 1),
          )
        "<" ->
          Data(
            ..acc,
            guard: Guard(x:, y:, facing: West),
            size: Size(..acc.size, w: acc.size.w + 1),
          )
        "#" ->
          Data(
            ..acc,
            boxes: dict.insert(acc.boxes, #(x, y), "#"),
            size: Size(..acc.size, w: acc.size.w + 1),
          )
        "." -> Data(..acc, size: Size(..acc.size, w: acc.size.w + 1))
        _ -> panic as "Invalid character"
      }
    }

    Data(..data, size: Size(data.size.w, data.size.h + 1))
  }
}

pub fn pt_1(input: Data) {
  simulate(
    input.guard,
    input.boxes,
    input.size,
    set.new() |> set.insert(#(input.guard.x, input.guard.y)),
  )
  |> set.size
}

fn simulate(
  guard: Guard,
  blocks: Dict(Coordinates, String),
  size: Size,
  acc: Set(Coordinates),
) {
  case dict.get(blocks, space_in_front(guard)) {
    Error(Nil) ->
      case move(guard, False) {
        Guard(x:, y:, ..) if x < 0 || y < 0 || x >= size.w || y >= size.h -> acc
        Guard(x:, y:, ..) as after ->
          simulate(after, blocks, size, set.insert(acc, #(x, y)))
      }
    Ok("#") -> simulate(move(guard, True), blocks, size, acc)
    Ok(_) -> panic as "Invalid input value"
  }
}

fn space_in_front(guard: Guard) -> Coordinates {
  case guard.facing {
    North -> #(guard.x, guard.y - 1)
    East -> #(guard.x + 1, guard.y)
    South -> #(guard.x, guard.y + 1)
    West -> #(guard.x - 1, guard.y)
  }
}

fn move(guard: Guard, blocked: Bool) -> Guard {
  case blocked {
    False ->
      case guard.facing {
        North -> Guard(..guard, y: guard.y - 1)
        East -> Guard(..guard, x: guard.x + 1)
        South -> Guard(..guard, y: guard.y + 1)
        West -> Guard(..guard, x: guard.x - 1)
      }
    True -> next_direction(guard)
  }
}

fn next_direction(guard: Guard) -> Guard {
  case guard.facing {
    North -> Guard(..guard, facing: East)
    East -> Guard(..guard, facing: South)
    South -> Guard(..guard, facing: West)
    West -> Guard(..guard, facing: North)
  }
}

pub fn pt_2(input: Data) {
  todo as "part 2 not implemented"
}
