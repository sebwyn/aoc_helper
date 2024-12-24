import gleam/result
import gleam/bool
import gleam/iterator
import gleam/int
import gleam/list
import gleam/string

type Grid(a) {
  Grid(rows: List(List(a)), width: Int, height: Int)
}

fn index_grid(grid: Grid(a), x: Int, y: Int) -> Result(a, Nil) {
  use <- bool.guard(bool.negate(0 <= x && x < grid.width && 0 <= y && y < grid.height), Error(Nil))

  iterator.zip(iterator.iterate(0, int.add(_, 1)), iterator.from_list(grid.rows))
  |> iterator.find_map(fn(y_row) { 
    case y_row.0 == y {
      False -> Error(Nil)
      True -> {
        iterator.zip(iterator.iterate(0, int.add(_, 1)), iterator.from_list(y_row.1))
        |> iterator.find_map(fn(x_val) {
          case x_val.0 == x {
            False -> Error(Nil)
            True -> { Ok(x_val.1) }
          }
        })
      }
    }
  }) 
}

fn parse(input: String) -> Result(Grid(Int), Nil) {
  input
  |> string.split("\n")
  |> list.filter(fn(s) { ! string.is_empty(s) })
  |> list.map(fn(s) { s |> string.split("") |> list.map(fn(a) { result.unwrap(int.parse(a), -1) }) })
  |> fn(rows) {
    use first <- result.map(list.first(rows))
    Grid(rows, width: list.length(first), height: list.length(rows))
  }
}

fn find_all_zeros(grid: Grid(Int)) -> List(#(Int, Int)) {
  grid.rows
  |> list.index_map(fn(a, i) { #(i, a) })
  |> list.flat_map(fn(i_a) { 
    i_a.1 
    |> list.index_map(fn(a, i) { #(i, a) }) 
    |> list.filter(fn(i_a) { i_a.1 == 0 }) 
    |> list.map(fn(x_a) { #(x_a.0, i_a.0)})
  })
}

fn find_all_neighboring_positions(pos: #(Int, Int)) {
  [
    #(pos.0 - 1, pos.1),
    #(pos.0 + 1, pos.1),
    #(pos.0, pos.1 - 1),
    #(pos.0, pos.1 + 1)
  ] 
}

fn find_all_possible_ends(grid: Grid(Int), val: Int, pos: #(Int, Int)) -> List(#(Int, Int)) {
  case val {
    9 -> [pos]
    val -> {
      find_all_neighboring_positions(pos)
      |> list.filter_map(fn(pos) { 
        use next_val <- result.try(index_grid(grid, pos.0, pos.1))
        use <- bool.guard(next_val != { val + 1 }, Error(Nil))
        Ok(#(next_val, pos))
      })
      |> list.flat_map(fn(a) { find_all_possible_ends(grid, a.0, a.1) }) 
    }
  }
}

pub fn part1(challenge_input: String) {
  let assert Ok(grid) = challenge_input |> parse 

  find_all_zeros(grid)
  |> list.map(fn(p) { find_all_possible_ends(grid, 0, p) |> list.unique |> list.length })
  |> int.sum
  |> int.to_string
}

fn find_all_possible_forks(grid: Grid(Int), val: Int, pos: #(Int, Int)) -> Int {
  case val {
    9 -> 1 
    val -> {
      find_all_neighboring_positions(pos)
      |> list.filter_map(fn(pos) { 
        use next_val <- result.try(index_grid(grid, pos.0, pos.1))
        use <- bool.guard(next_val != { val + 1 }, Error(Nil))
        Ok(#(next_val, pos))
      })
      |> list.map(fn(a) { find_all_possible_forks(grid, a.0, a.1) }) 
      |> int.sum
    }
  }
}

pub fn part2(challenge_input: String) -> String {
  let assert Ok(grid) = challenge_input |> parse 
  
  find_all_zeros(grid)
  |> list.map(fn(p) { find_all_possible_forks(grid, 0, p) })
  |> int.sum
  |> int.to_string
}
