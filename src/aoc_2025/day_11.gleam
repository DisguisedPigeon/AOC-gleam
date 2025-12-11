import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import rememo/memo

pub fn parse(input: String) -> Dict(String, Set(String)) {
  string.split(input, "\n")
  |> list.fold(dict.new(), fn(acc, line) {
    let assert Ok(#(name, next)) = string.split_once(line, ":")

    string.trim(next)
    |> string.split(" ")
    |> set.from_list()
    |> dict.insert(acc, string.trim(name), _)
  })
}

pub fn pt_1(input: Dict(String, Set(String))) -> Int {
  count_paths("you", "out", input)
}

pub fn pt_2(input: Dict(String, Set(String))) -> Int {
  count_paths_through(from: "svr", nodes: input, to: "out", through: [
    "fft",
    "dac",
  ])
}

fn count_paths_through(
  from origin: String,
  nodes nodes: Dict(String, Set(String)),
  to destination: String,
  through through: List(String),
) -> Int {
  [origin, ..list.append(through, [destination])]
  |> list.window_by_2()
  |> list.map(fn(v) {
    let #(origin, destination) = v
    count_paths(origin, destination, nodes)
  })
  |> int.product
}

fn count_paths(
  origin: String,
  destination: String,
  nodes: Dict(String, Set(String)),
) -> Int {
  use cache <- memo.create()
  do_count(origin, destination, nodes, 0, cache)
}

fn do_count(
  origin: String,
  destination: String,
  nodes: Dict(String, Set(String)),
  acc: Int,
  cache,
) -> Int {
  use <- bool.guard(when: origin == destination, return: acc + 1)

  let current_iteration = {
    use <- memo.memoize(cache, #(origin, destination))
    case dict.get(nodes, origin) {
      Ok(v) ->
        set.fold(v, 0, fn(acc, e) {
          do_count(e, destination, nodes, acc, cache)
        })

      // We got to out while searching for a "through" node (fft or dac), no path avaliable
      Error(Nil) -> 0
    }
  }
  current_iteration + acc
}
