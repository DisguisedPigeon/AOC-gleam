import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub type Rotation {
  Down(Int)
  Up(Int)
}

pub fn parse(input: String) -> List(Rotation) {
  input
  |> string.split(on: "\n")
  |> list.map(with: fn(line) {
    case string.pop_grapheme(line) {
      Ok(#("L", rest)) -> {
        use number <- result.try(int.parse(rest))
        Ok(Down(number))
      }
      Ok(#("R", rest)) -> {
        use number <- result.try(int.parse(rest))
        Ok(Up(number))
      }
      _ -> panic as "Unexpected direction"
    }
    |> result.lazy_unwrap(fn() {
      panic as { "Parsing failed on " <> string.inspect(line) }
    })
  })
}

type Dial {
  Dial(pointing: Int)
}

pub fn pt_1(rotations: List(Rotation)) {
  #(Dial(50), 0)
  |> list.fold(rotations, _, turn_and_count_0s)
  |> pair.second
}

pub fn pt_2(rotations: List(Rotation)) {
  #(Dial(50), 0)
  |> list.fold(rotations, _, turn_and_count_0_passes)
  |> pair.second
}

fn turn(dial: Dial, rotation: Rotation) -> #(Dial, Int) {
  case rotation {
    Down(n) -> {
      let zero_hits = { { 100 - dial.pointing } % 100 + n } / 100

      let assert Ok(dial) = int.modulo(dial.pointing - n, 100)

      #(Dial(dial), zero_hits)
    }

    Up(n) -> {
      let zero_hits = { dial.pointing + n } / 100

      let assert Ok(dial) = int.modulo(dial.pointing + n, 100)

      #(Dial(dial), zero_hits)
    }
  }
}

fn points_at_0(dial: Dial) {
  dial.pointing == 0
}

fn turn_and_count_0s(acc, rotation) {
  let #(dial, count) = acc
  let #(dial, _0_passes) = turn(dial, rotation)

  case points_at_0(dial) {
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
