import gleam/io
import gleam/int
import gleam/dict.{type Dict}
import gleam/result
import gleam/string
import gleam/list
import gleam/set.{type Set}

type Grid {
  Grid(lookup: Dict(#(Int, Int), String))
}

fn parse(input: String) -> Grid {
  input
  |> string.split("\n")
  |> list.filter(fn(a) { ! string.is_empty(a) })
  |> list.index_map(fn(row, y) { #(y, row) })
  |> list.flat_map(fn(y_row) {
    let #(y, row) = y_row
    row
    |> string.split("") 
    |> list.index_map(fn(c, x) { #(#(x, y), c) }) 
  })
  |> dict.from_list
  |> Grid
}

fn get_neighboring_cells(pos: #(Int, Int)) -> List(#(Int, Int)) {
  [
    #(pos.0 - 1, pos.1),
    #(pos.0 + 1, pos.1),
    #(pos.0, pos.1 - 1),
    #(pos.0, pos.1 + 1)
  ] 
}

fn visit_subregions(grid: Grid, subregion_starts: List(#(Int, Int)), visited: Set(#(Int, Int))) -> #(Set(#(Int, Int)), Int, Int) {
  case subregion_starts {
    [] -> #(set.new(), 0, 0) 
    [start, ..starts] -> {
      let #(subregion, area, perimeter) = recurse_region_calculating_area_and_perimeter(grid, start, visited)
      let #(next_subregion, next_area, next_perimeter) = visit_subregions(grid, starts, set.union(visited, subregion))
      #(set.union(subregion, next_subregion), area + next_area, perimeter + next_perimeter)
    }
  }
}

fn recurse_region_calculating_area_and_perimeter(
  grid: Grid, 
  pos: #(Int, Int),
  visited: Set(#(Int, Int)), 
) -> #(Set(#(Int, Int)), Int, Int) {
  let assert Ok(region_crop_type) = dict.get(grid.lookup, pos)

  let neighbors_within_region = 
    get_neighboring_cells(pos) 
    |> list.filter(fn(pos) { 
        dict.get(grid.lookup, pos)
        |> result.map(fn(neighboring_crop) { neighboring_crop == region_crop_type })
        |> result.unwrap(False)
    })
  
  let newly_visited = set.from_list([pos, ..neighbors_within_region])
  let #(subregion, subregion_area, subregion_perimeter) = 
    neighbors_within_region
    |> list.filter(fn(pos) { !set.contains(visited, pos) })
    |> visit_subregions(grid, _, set.union(visited, newly_visited))

  #(
    set.union(set.from_list([pos]), subregion),
    subregion_area + 1, 
    subregion_perimeter + { 4 - list.length(neighbors_within_region) }
  )
}

fn do_calculate_fence_cost(grid: Grid, unvisited: Set(#(Int, Int)), fence_cost: Int) -> Int {
  case unvisited |> set.to_list |> list.first  {
    Error(Nil) -> fence_cost
    Ok(pos) -> {
      let #(visited, area, perimeter) = recurse_region_calculating_area_and_perimeter(grid, pos, set.new())
      do_calculate_fence_cost(grid, set.difference(unvisited, visited), fence_cost + { area * perimeter }) 
    }
  }
}

pub fn part1(challenge_input: String) -> String {
  let grid = parse(challenge_input)
  let unvisited = grid.lookup |> dict.keys |> set.from_list
  
  io.println(grid.lookup |> string.inspect)

  do_calculate_fence_cost(grid, unvisited, 0)
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  "Not Implemented"
}
