import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import glearray

pub type Disk =
  glearray.Array(Segment)

pub type BlockDisk =
  List(Block)

pub type Segment {
  File(id: Int)
  Free
}

pub type Block {
  Block(length: Int, id: Int)
  Space(length: Int)
}

pub fn parse(input: String) -> Disk {
  let l =
    string.to_graphemes(input)
    |> list.filter_map(int.parse)
  case list.length(l) {
    a if a % 2 == 0 ->
      list.window_by_2(l)
      |> list.index_fold([], fn(acc, v, i) {
        let #(block, free) = v
        case i % 2 == 0 {
          True -> [list.repeat(Free, free), list.repeat(File(i), block), ..acc]
          False -> acc
        }
      })
      |> list.flatten
    _ -> {
      let assert Ok(last) = list.last(l)
      let list =
        list.window_by_2(l)
        |> list.index_fold([], fn(acc, v, i) {
          let #(block, free) = v
          case i % 2 == 0 {
            True -> [
              list.repeat(Free, free),
              list.repeat(File(i / 2), block),
              ..acc
            ]
            False -> acc
          }
        })

      [list.repeat(File(list.length(list) / 2), last), ..list] |> list.flatten
    }
  }
  |> list.reverse
  |> glearray.from_list
}

pub fn pt_1(input: Disk) -> Int {
  compact(input)
  |> checksum
}

pub fn pt_2(_: Disk) -> Int {
  panic as "not intended"
}

fn compact(disk: Disk) -> Disk {
  let size = glearray.length(disk)
  do_compact(disk, 0, size - 1)
}

fn do_compact(disk: Disk, space_index: Int, block_index: Int) -> Disk {
  let space_index = find_space(disk, space_index)
  let block_index = find_block(disk, block_index)
  use <- bool.guard(when: space_index > block_index, return: disk)

  let block =
    glearray.get(disk, block_index)
    |> result.lazy_unwrap(fn() { panic })

  glearray.copy_set(disk, space_index, block)
  |> result.lazy_unwrap(fn() { panic })
  |> glearray.copy_set(block_index, Free)
  |> result.lazy_unwrap(fn() { panic })
  |> do_compact(space_index, block_index)
}

fn find_space(disk: glearray.Array(Segment), space_index: Int) -> Int {
  case glearray.get(disk, space_index) {
    Ok(Free) -> space_index
    Ok(_) -> find_space(disk, space_index + 1)
    Error(_) -> -1
  }
}

fn find_block(disk: glearray.Array(Segment), block_index: Int) -> Int {
  case glearray.get(disk, block_index) {
    Ok(File(_)) -> block_index
    Ok(_) -> find_block(disk, block_index - 1)
    Error(_) -> -1
  }
}

fn checksum(disk: Disk) -> Int {
  glearray.to_list(disk)
  |> list.index_fold(0, fn(acc, element, index) {
    case element {
      File(id:) -> index * id + acc
      Free -> acc
    }
  })
}
