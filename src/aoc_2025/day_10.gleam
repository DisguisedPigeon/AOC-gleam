import gleam/bool
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub opaque type Machine {
  Machine(
    current_lights: List(Bool),
    current_joltages: List(Int),
    press_history: List(Set(Int)),
    wirings: List(Set(Int)),
    needed_lights: List(Bool),
    needed_joltages: List(Int),
  )
}

pub fn parse(input: String) -> List(Machine) {
  string.split(input, "\n")
  |> list.map(string.split_once(_, " "))
  |> list.map(fn(line) {
    let assert Ok(#(indicator_lights, rest)) = line
    let needed_lights =
      indicator_lights
      |> string.drop_start(1)
      |> string.drop_end(1)
      |> string.to_graphemes()
      |> list.map(fn(light) {
        case light {
          "." -> False
          "#" -> True
          _ -> panic
        }
      })

    let assert [needed_joltages, ..wirings] =
      string.split(rest, " ")
      |> list.reverse

    let needed_joltages =
      string.drop_start(needed_joltages, 1)
      |> string.drop_end(1)
      |> string.split(",")
      |> list.filter_map(int.parse)

    let wirings =
      list.map(wirings, fn(wiring) {
        string.drop_start(wiring, 1)
        |> string.drop_end(1)
        |> string.split(",")
        |> list.filter_map(int.parse)
        |> set.from_list
      })

    Machine(
      current_lights: list.map(needed_lights, fn(_) { False }),
      current_joltages: list.map(needed_joltages, fn(_) { 0 }),
      press_history: [],
      wirings:,
      needed_lights:,
      needed_joltages:,
    )
  })
}

pub fn pt_1(input: List(Machine)) {
  list.map(input, solve)
  |> list.map(list.length)
  |> int.sum
}

fn solve(machine: Machine) -> List(Set(Int)) {
  possible_presses(machine)
  |> do_solve()
}

fn do_solve(candidates: List(Machine)) -> List(Set(Int)) {
  case
    list.find(candidates, fn(candidate) { distance_to_solved(candidate) == 0 })
  {
    Error(Nil) ->
      list.map(candidates, possible_presses)
      |> list.flatten()
      |> do_solve()

    Ok(m) -> m.press_history
  }
}

fn distance_to_solved(machine: Machine) -> Int {
  list.map2(
    machine.needed_lights,
    machine.current_lights,
    with: bool.exclusive_nor,
  )
  |> list.count(bool.negate)
}

fn possible_presses(machine: Machine) -> List(Machine) {
  list.map(machine.wirings, update(machine, _))
}

fn update(machine: Machine, press: Set(Int)) -> Machine {
  let press_history = [press, ..machine.press_history]

  let current_lights =
    list.index_map(machine.current_lights, fn(light, index) {
      case set.contains(press, index) {
        True -> !light
        False -> light
      }
    })

  Machine(..machine, current_lights:, press_history:)
}

pub fn pt_2(_input: List(Machine)) {
  panic as "I'm too dumb for this shit"
}
