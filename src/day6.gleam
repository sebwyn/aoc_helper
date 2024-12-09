import gleam/io
import gleam/set.{type Set}
import gleam/int
import gleam/result
import gleam/list
import gleam/string

fn enumerate(l: List(a)) -> List(#(Int, a)) { l |> list.index_map(fn(x, i) { #(i, x)})
}

fn parse(challenge_input: String) -> #(#(Int, Int), Set(#(Int, Int)), #(Int, Int)) {
  let rows = string.split(challenge_input, "\n") |> list.filter(fn(r) { ! string.is_empty(r) })

  let assert Ok(guard_starting_pos) = 
    enumerate(rows) 
    |> list.find_map(fn(indexed_l) { 
      string.split(indexed_l.1, "")
      |> enumerate
      |> list.find_map(fn(indexed_c) { 
        case indexed_c.1 {
          "^" -> Ok(#(indexed_c.0, indexed_l.0))
          _ -> Error(Nil)
        } 
      })
    })

  let obstacle_positions = enumerate(rows)
    |> list.flat_map(fn(indexed_l) { 
      string.split(indexed_l.1, "")
      |> enumerate
      |> list.filter_map(fn(indexed_c) { 
        case indexed_c.1 {
          "#" -> Ok(#(indexed_c.0, indexed_l.0))
          _ -> Error(Nil)
        } 
      })
    })
    |> set.from_list

    let grid_width = list.first(rows) |> result.unwrap("") |> string.length
    let grid_height = list.length(rows)

    #(guard_starting_pos, obstacle_positions, #(grid_width, grid_height))
}

type Direction {
  North
  South
  East
  West
}

fn turn_right(dir: Direction) -> Direction {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn progress_guard(
  guard_pos: #(Int, Int),
  guard_dir: Direction,
  obstacles: Set(#(Int, Int)),
  grid_size: #(Int, Int),
  visited: List(#(Int, Int))
) -> List(#(Int, Int)){
  let #(dx, dy) =
    case guard_dir {
      East -> #(1, 0)
      West -> #(-1, 0)
      North -> #(0, -1)
      South -> #(0, 1)
    }
  
  let next_pos = #(guard_pos.0 + dx, guard_pos.1 + dy)
  case 0 <= next_pos.0 && next_pos.0 < grid_size.0 && 0 <= next_pos.1 && next_pos.1 < grid_size.1 {
    True -> case set.contains(obstacles, next_pos) {
      True -> progress_guard(guard_pos, turn_right(guard_dir), obstacles, grid_size, [ guard_pos, ..visited]) 
      False -> { progress_guard(next_pos, guard_dir, obstacles, grid_size, [ next_pos, ..visited]) }
    }
    False -> visited
  }
}

fn progress_guard_checking_for_loop(
  guard_pos: #(Int, Int),
  guard_dir: Direction,
  obstacles: Set(#(Int, Int)),
  grid_size: #(Int, Int),
  visited: Set(#(#(Int, Int), Direction)),
) -> Bool {
  let #(dx, dy) =
    case guard_dir {
      East -> #(1, 0)
      West -> #(-1, 0)
      North -> #(0, -1)
      South -> #(0, 1)
    }
  
  let next_pos = #(guard_pos.0 + dx, guard_pos.1 + dy)
  case set.contains(visited, #(next_pos, guard_dir)) {
    True -> True
    False -> {
      case 0 <= next_pos.0 && next_pos.0 < grid_size.0 && 0 <= next_pos.1 && next_pos.1 < grid_size.1 {
        False -> False
        True -> case set.contains(obstacles, next_pos) {
          True -> progress_guard_checking_for_loop(guard_pos, turn_right(guard_dir), obstacles, grid_size, set.insert(visited, #(guard_pos, guard_dir)))
          False -> progress_guard_checking_for_loop(next_pos, guard_dir, obstacles, grid_size, set.insert(visited, #(next_pos, guard_dir)))
        }
      }
    }
  }
}

pub fn part1(challenge_input: String) { 
  let #(guard_pos, obstacles, grid_size) = parse(challenge_input) 
  progress_guard(guard_pos, North, obstacles, grid_size, [guard_pos])
  |> list.unique
  |> list.length
  |> int.to_string
}

//brute force attempt for part 2
pub fn part2(challenge_input: String) { 
  let #(guard_pos, obstacles, grid_size) = parse(challenge_input) 
  progress_guard(guard_pos, North, obstacles, grid_size, [])
  |> list.unique
  |> list.count(fn(pos) { progress_guard_checking_for_loop(guard_pos, North, set.insert(obstacles, pos), grid_size, [#(guard_pos, North)] |> set.from_list) })
  |> int.to_string
}
