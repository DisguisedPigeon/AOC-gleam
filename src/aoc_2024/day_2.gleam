import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> list.map(fn(str) {
    string.split(str, on: " ")
    |> list.filter_map(with: int.parse)
  })
}

type LevelStatus {
  Safe(list: List(Int), asc: Option(Bool))
  Unsafe(failing: Int, list: List(Int))
}

pub fn pt_1(input: List(List(Int))) -> Int {
  list.fold(over: input, from: 0, with: fn(acc, report) {
    case check_report(report) {
      Safe(..) -> acc + 1
      Unsafe(..) -> acc
    }
  })
}

fn check_report(report: List(Int)) -> LevelStatus {
  list.index_fold(over: report, from: Safe([], None), with: safe_validator)
}

fn safe_validator(acc: LevelStatus, level: Int, index: Int) -> LevelStatus {
  case acc {
    Safe([], _) -> Safe([level], None)

    // Ascending and valid
    Safe([prev, ..] as list, Some(True)) if level > prev && level - prev <= 3 ->
      Safe(..acc, list: [level, ..list])

    // Descending and valid
    Safe([prev, ..] as list, Some(False)) if level < prev && prev - level <= 3 ->
      Safe(..acc, list: [level, ..list])

    // Second value, ascending
    Safe([prev, ..] as list, None) if level > prev && level - prev <= 3 ->
      Safe([level, ..list], Some(True))

    // Second value, descending
    Safe([prev, ..] as list, None) if level < prev && prev - level <= 3 ->
      Safe([level, ..list], Some(False))

    //Invalid
    Safe(list:, ..) -> Unsafe(failing: index, list: [level, ..list])
    Unsafe(failing:, list:) -> Unsafe(failing:, list: [level, ..list])
  }
}

pub fn pt_2(input: List(List(Int))) -> Int {
  list.fold(over: input, from: 0, with: fn(acc, report) {
    case check_report(report) |> try_recover() {
      Safe(..) -> acc + 1
      Unsafe(..) -> acc
    }
  })
}

fn try_recover(result) {
  case result {
    Safe(..) -> result
    Unsafe(failing:, list:) -> {
      let list = list |> list.reverse

      use <- recovery(list, failing)
      use <- recovery(list, failing - 1)
      use <- recovery(list, failing - 2)
      use <- recovery(list, failing + 1)

      result
    }
  }
}

fn recovery(
  list: List(Int),
  index_to_remove: Int,
  continue: fn() -> LevelStatus,
) -> LevelStatus {
  case remove_element(list, index_to_remove) |> check_report {
    Safe(..) as result -> result
    _ -> continue()
  }
}

fn remove_element(report, index) {
  list.index_fold(over: report, from: [], with: fn(acc, level, current) {
    case current == index {
      True -> acc
      False -> [level, ..acc]
    }
  })
}
