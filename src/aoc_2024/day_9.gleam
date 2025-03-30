import gleam/int
import gleam/list
import gleam/string

pub type Disk =
  List(Segment)

pub type Segment {
  Block(id: Int)
  Free
}

pub fn parse(input: String) -> Disk {
  let charlist = string.to_graphemes(input) |> list.filter_map(int.parse)
  {
    use acc: List(Segment), element, idx <- list.index_fold(charlist, [])
    case idx % 2 {
      0 -> [list.repeat(Block(idx / 2), element), acc] |> list.flatten
      1 -> [list.repeat(Free, element), acc] |> list.flatten
      _ -> panic as "GAMMA RAY DETECTED"
    }
  }
  |> list.reverse
}

pub fn pt_1(input: Disk) {
  compact(input)
  |> checksum()
}

pub fn pt_2(input: Disk) {
  todo
}

fn compact(disk: Disk) -> Disk {
  let arr = glearray.from_list(disk)
  {
    use #(last_block_idx, acc), element, index <- list.index_fold(
      disk,
      #(glearray.length(arr), []),
    )
    case element, index < last_block_idx {
      Block(_), True -> #(last_block_idx, [element, ..acc])
      Free, True -> {
        let #(block, last_block_idx) = find_previous_block(arr, last_block_idx)
        case index < last_block_idx {
          True -> #(last_block_idx, [block, ..acc])
          False -> #(last_block_idx, [element, ..acc])
        }
      }
      _, False -> #(last_block_idx, [Free, ..acc])
    }
  }.1
  // As I'm prepending the elements to acc on each iteration, the list ends up reversed after the fold
  |> list.reverse
}

fn find_previous_block(
  arr: glearray.Array(Segment),
  last_block_idx: Int,
) -> #(Segment, Int) {
  let indices = list.range(last_block_idx - 1, 0)
  use acc, idx <- list.fold_until(indices, #(Free, 0))
  case glearray.get(arr, idx) {
    Error(_) -> list.Continue(acc)
    Ok(Free) -> list.Continue(acc)
    Ok(Block(_) as b) -> list.Stop(#(b, idx))
  }
}

fn checksum(disk: Disk) -> Int {
  use acc, element, index <- list.index_fold(disk, 0)
  case element {
    Block(id:) -> index * id + acc
    Free -> acc
  }
}
