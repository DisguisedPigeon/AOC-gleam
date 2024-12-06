import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn parse(input: String) -> #(List(List(Int)), dict.Dict(Int, List(Int))) {
  let assert [order, updates] = string.split(input, "\n\n")

  let updates =
    string.split(updates, "\n")
    |> list.map(string.split(_, ","))
    |> list.map(fn(e) { list.filter_map(e, int.parse) })

  let order = {
    use acc: dict.Dict(Int, List(Int)), element: String <- list.fold(
      string.split(order, "\n"),
      dict.new(),
    )
    let assert [fst, snd] = string.split(element, "|")
    let assert Ok(fst) = int.parse(fst)
    let assert Ok(snd) = int.parse(snd)

    dict.upsert(in: acc, update: snd, with: fn(v) {
      case v {
        option.None -> [fst]
        option.Some(v) -> [fst, ..v]
      }
    })
    |> dict.upsert(update: fst, with: fn(v) {
      case v {
        option.None -> []
        option.Some(v) -> v
      }
    })
  }

  #(updates, order)
}

pub fn pt_1(input: #(List(List(Int)), dict.Dict(Int, List(Int)))) {
  use acc, update <- list.fold(input.0, 0)
  let is_valid =
    {
      use previous, element <- list.fold_until(update, Ok([]))
      let assert Ok(previous) = previous
      let parents = get_parents(element, input.1)
      case list.filter(previous, fn(e) { !list.contains(parents, e) }) {
        [] -> list.Continue(Ok([element, ..previous]))
        [_, ..] -> {
          list.Stop(Error(Nil))
        }
      }
    }
    |> result.map(fn(_) { True })
    |> result.unwrap(False)

  case is_valid {
    True -> {
      middle(update) + acc
    }
    False -> acc
  }
}

fn middle(l: List(Int)) -> Int {
  list.index_fold(l, 0, fn(acc, e, idx) {
    case idx == list.length(l) / 2 {
      False -> acc
      True -> e
    }
  })
}

fn get_parents(e: a, d: dict.Dict(a, List(a))) -> List(a) {
  case dict.get(d, e) {
    Error(_) -> {
      panic as "element not in dict"
    }
    Ok([]) -> [e]
    Ok([_, ..] as l) ->
      list.map(l, get_parents(_, d))
      |> list.flatten
      |> list.unique
      |> list.prepend(e)
  }
}

pub fn pt_2(input: #(List(List(Int)), dict.Dict(Int, List(Int)))) {
  todo as "part 2 not implemented"
}
