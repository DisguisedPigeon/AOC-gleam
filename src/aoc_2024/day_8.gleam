import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

pub type Coordinates =
  #(Int, Int)

const valid_signals = [
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
  "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
  "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
  "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
]

pub type Data {
  Data(size: Size, network: Grid)
}

pub type Size {
  Size(w: Int, h: Int)
}

pub type Grid =
  Dict(Coordinates, Thing)

pub type Thing {
  Antenna(id: String)
  Void
}

pub fn parse(input: String) -> Data {
  let chars =
    string.split(input, "\n")
    |> list.map(string.to_graphemes)

  let size = {
    let assert Ok(hd) = list.first(chars)
    Size(w: list.length(hd), h: list.length(chars))
  }

  use acc, line, j <- list.index_fold(over: chars, from: Data(size, dict.new()))

  use Data(size:, network:), element, i <- list.index_fold(
    over: line,
    from: acc,
  )
  case list.contains(valid_signals, element) {
    False -> Data(size:, network:)
    True ->
      Data(
        size:,
        network: dict.insert(
          into: network,
          for: #(i, j),
          insert: Antenna(element),
        ),
      )
  }
}

pub fn pt_1(input: Data) {
  dict.keys(input.network)
  |> list.combination_pairs
  |> list.map(find_one_antinode_for_pair(_, input.network))
  |> list.flatten
  |> list.filter(fn(e) {
    e.0 >= 0 && e.0 < input.size.w && e.1 >= 0 && e.1 < input.size.h
  })
  |> list.unique
  |> list.length
}

fn find_one_antinode_for_pair(
  pair: #(Coordinates, Coordinates),
  network: Dict(#(Int, Int), Thing),
) -> List(Coordinates) {
  let #(va, vb) = pair
  case dict.get(network, va), dict.get(network, vb) {
    Ok(Antenna(a)), Ok(Antenna(b)) if a == b -> {
      let vab = #(vb.0 - va.0, vb.1 - va.1)
      [#(va.0 - vab.0, va.1 - vab.1), #(vb.0 + vab.0, vb.1 + vab.1)]
    }
    _, _ -> []
  }
}

pub fn pt_2(input: Data) {
  dict.keys(input.network)
  |> list.combination_pairs
  |> list.map(find_antinodes_for_pair(_, input.network, input.size))
  |> list.flatten
  |> list.filter(fn(e) {
    e.0 >= 0 && e.0 < input.size.w && e.1 >= 0 && e.1 < input.size.h
  })
  |> list.unique
  |> list.length
}

fn find_antinodes_for_pair(
  pair: #(Coordinates, Coordinates),
  network: Dict(Coordinates, Thing),
  size: Size,
) -> List(#(Int, Int)) {
  let #(va, vb) = pair
  case dict.get(network, va), dict.get(network, vb) {
    Ok(Antenna(a)), Ok(Antenna(b)) if a == b -> {
      let vab = #(vb.0 - va.0, vb.1 - va.1)
      let max_side = int.max(size.w, size.h)
      use acc, element <- list.fold(list.range(0, max_side), [])
      [
        #(va.0 - vab.0 * element, va.1 - vab.1 * element),
        #(vb.0 + vab.0 * element, vb.1 + vab.1 * element),
        ..acc
      ]
    }
    _, _ -> []
  }
}
