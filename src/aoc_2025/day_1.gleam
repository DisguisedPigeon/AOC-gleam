import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub type Rotation {
  Down(Int)
  Up(Int)
}

pub type Dial {
  Dial(position: Int)
}

pub fn parse(input: String) -> List(Rotation) {
  string.split(input, on: "\n")
  |> list.try_map(with: fn(line) {
    case string.pop_grapheme(line) {
      Ok(#("L", rest)) -> int.parse(rest) |> result.map(Down)
      Ok(#("R", rest)) -> int.parse(rest) |> result.map(Up)

      _ -> panic as "Unexpected direction"
    }
  })
  |> result.lazy_unwrap(fn() { panic as "Parsing failed" })
}

pub fn pt_1(rotations: List(Rotation)) -> Int {
  // Starting value, #(Dial, Number of hits)
  #(Dial(50), 0)
  |> list.fold(rotations, _, turn_and_count_0s)
  // Extract the number of zeros from the tuple
  |> pair.second
}

pub fn pt_2(rotations: List(Rotation)) -> Int {
  // Starting value, #(Dial, Number of hits)
  #(Dial(50), 0)
  |> list.fold(rotations, _, turn_and_count_0_passes)
  // Extract the number of zeros from the tuple
  |> pair.second
}

fn turn(dial: Dial, rotation: Rotation) -> #(Dial, Int) {
  case rotation {
    Down(n) -> {
      let assert Ok(position) = int.modulo(dial.position - n, 100)

      let reverted_position = { 100 - dial.position } % 100
      let movement_as_positive = reverted_position + n
      let zero_hitcount = movement_as_positive / 100

      #(Dial(position), zero_hitcount)
    }

    Up(n) -> {
      let assert Ok(position) = int.modulo(dial.position + n, 100)
      let zero_hitcount = { dial.position + n } / 100

      #(Dial(position), zero_hitcount)
    }
  }
}

fn turn_and_count_0s(acc: #(Dial, Int), rotation: Rotation) -> #(Dial, Int) {
  let #(dial, count) = acc
  let #(dial, _needed_for_part_2) = turn(dial, rotation)

  case dial.position == 0 {
    True -> #(dial, count + 1)
    False -> #(dial, count)
  }
}

fn turn_and_count_0_passes(
  acc: #(Dial, Int),
  rotation: Rotation,
) -> #(Dial, Int) {
  let #(dial, count) = acc
  let #(dial, passes) = turn(dial, rotation)

  #(dial, count + passes)
}
