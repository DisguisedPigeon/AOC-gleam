import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/string
import graph.{type Directed, type Graph, type Node, Node}

type Order =
  Graph(Directed, Nil, Nil)

type Update =
  List(Int)

pub type Data {
  Data(order: Order, updates: List(Update))
}

fn might_insert_node(graph: Order, node: Node(Nil)) -> Order {
  case graph |> graph.match(node.id) {
    Error(_) -> graph.insert_node(graph, node)
    Ok(_) -> graph
  }
}

pub fn parse(input: String) -> Data {
  let assert [order, updates] = string.split(input, "\n\n")

  let updates =
    string.split(updates, "\n")
    |> list.map(string.split(_, ","))
    |> list.map(fn(e) { list.filter_map(e, int.parse) })

  let order = {
    use acc, element <- list.fold(string.split(order, "\n"), graph.new())
    let assert [fst, snd] = string.split(element, "|")
    let assert Ok(fst) = int.parse(fst)
    let assert Ok(snd) = int.parse(snd)

    might_insert_node(acc, Node(fst, Nil))
    |> might_insert_node(Node(snd, Nil))
    |> graph.insert_directed_edge(Nil, fst, snd)
  }

  Data(order, updates)
}

pub fn pt_1(input: Data) -> Int {
  use acc, update <- list.fold(input.updates, 0)
  case safe(update, input.order) {
    True -> acc + middle(update)
    False -> acc
  }
}

fn middle(update: Update) -> Int {
  let len = list.length(update)
  use acc, element, idx <- list.index_fold(update, 0)
  case Nil {
    _ if idx == len / 2 -> element
    _ -> acc
  }
}

fn safe(update: Update, order: Order) -> Bool {
  use acc, #(before, after) <- list.fold(list.window_by_2(update), True)
  let assert Ok(ctx) = graph.get_context(order, before)
  case ctx.outgoing |> dict.get(after) {
    Error(_) -> False
    Ok(_) -> acc
  }
}

pub fn pt_2(input: Data) {
  use acc, update <- list.fold(input.updates, 0)
  case safe(update, input.order) {
    True -> acc
    False ->
      case
        list.sort(update, fn(a, b) { sorter(a, b, input.order) })
        |> safe(input.order)
      {
        False -> panic as "failed"
        True ->
          acc
          + middle(list.sort(update, fn(a, b) { sorter(a, b, input.order) }))
      }
  }
}

fn sorter(this: Int, other: Int, order: Order) -> order.Order {
  let assert Ok(ctx) = graph.get_context(order, this)
  case ctx.outgoing |> dict.get(other) {
    Error(_) -> order.Gt
    Ok(_) -> order.Lt
  }
}
