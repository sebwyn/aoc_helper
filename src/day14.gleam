import gleam/iterator
import gleam/io
import gleam/dict
import gleam/result
import gleam/int
import gleam/list
import gleam/regex
import gleam/string
import gleam/option.{type Option, Some, None}

type Robot {
  Robot(position: #(Int, Int), velocity: #(Int, Int))
}

fn parse(input: String) -> Result(List(Robot), Nil) {
  let assert Ok(robot_regex) = regex.from_string("p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)")

  input
  |> string.split("\n")
  |> list.filter(fn(line) { !string.is_empty(line) })
  |> list.try_map(fn(line) {
    use match <- result.try(regex.scan(robot_regex, line) |> list.first)
    let assert Ok([p_x, p_y, v_x, v_y]) = match.submatches |> option.values |> list.try_map(int.parse)
    Ok(Robot(position: #(p_x, p_y), velocity: #(v_x, v_y)))
  }) 
}

pub fn get_quadrant(position: #(Int, Int)) -> Option(Int) {
  case position.0, position.1 {
    x, y if x < 50 && y < 51 -> Some(0) 
    x, y if x > 50 && y < 51 -> Some(1) 
    x, y if x > 50 && y > 51 -> Some(2) 
    x, y if x < 50 && y > 51 -> Some(3) 
    _, _ -> None
  }
}

pub fn part1(challenge_input: String) -> String {
  let assert Ok(robots) = challenge_input |> parse
  
  robots
  |> list.map(fn(robot) { #(robot.position.0 + robot.velocity.0 * 100, robot.position.1 + robot.velocity.1 * 100) })
  |> list.try_map(fn(position) { 
    use modded_x <- result.try(int.modulo(position.0, 101))
    use modded_y <- result.try(int.modulo(position.1, 103))
    Ok(#(modded_x, modded_y))
  }) 
  |> result.unwrap([])
  |> list.group(get_quadrant)
  |> dict.filter(fn(quadrant, _) { option.is_some(quadrant) })
  |> dict.values()
  |> list.map(list.length)
  |> list.reduce(int.multiply)
  |> result.map(int.to_string)
  |> result.unwrap("Didn't find any valid robots")
}

fn place_robot_in_grid(grid: List(List(String)), robot: #(Int, Int)) -> List(List(String)) {
  let first_lines = list.take(grid, robot.1) 
  let assert [robot_line, ..last_lines] = list.drop(grid, robot.1) 

  let row_before = list.take(robot_line, robot.0)
  let row_after = list.drop(robot_line, robot.0 + 1) 
  
  [
    first_lines,
    [list.flatten([row_before, ["R"], row_after])],
    last_lines
  ]
  |> list.flatten
}

fn compute_quadrants(positions: List(#(Int, Int))) -> #(Int, Int, Int, Int) {
  let quadrant_dictionary = 
    positions
    |> list.group(get_quadrant)
    |> dict.filter(fn(quadrant, _) { option.is_some(quadrant) })
    |> dict.map_values(fn(_, positions) { list.length(positions) })

  let quadrant1 = dict.get(quadrant_dictionary, Some(0)) |> result.unwrap(0)
  let quadrant2 = dict.get(quadrant_dictionary, Some(1)) |> result.unwrap(0)
  let quadrant3 = dict.get(quadrant_dictionary, Some(2)) |> result.unwrap(0)
  let quadrant4 = dict.get(quadrant_dictionary, Some(3)) |> result.unwrap(0)

  #(quadrant1, quadrant2, quadrant3, quadrant4)
}

fn compute_safety_score(robots: List(#(Int, Int))) -> Int {
  robots
  |> list.group(get_quadrant)
  |> dict.filter(fn(quadrant, _) { option.is_some(quadrant) })
  |> dict.values()
  |> list.map(list.length)
  |> list.reduce(int.multiply)
  |> result.unwrap(0)
}

fn simulate_robots(robots: List(Robot), time: Int) -> List(#(Int, Int)) {
  robots
  |> list.map(fn(robot) { #(robot.position.0 + robot.velocity.0 * time, robot.position.1 + robot.velocity.1 * time) })
  |> list.try_map(fn(position) { 
    use modded_x <- result.try(int.modulo(position.0, 101))
    use modded_y <- result.try(int.modulo(position.1, 103))
    Ok(#(modded_x, modded_y))
  }) 
  |> result.unwrap([])
}

pub fn part2(challenge_input: String) -> String {
  let assert Ok(robots) = challenge_input |> parse
  
  let empty_grid = 
    list.repeat(".", 101)
    |> list.repeat(103)
  
  iterator.iterate(0, int.add(_, 1))
  |> iterator.map(simulate_robots(robots, _))
  |> iterator.filter(fn(robots) { 
    let #(q1, q2, q3, q4) = compute_quadrants(robots)
    q1 != q2 && q2 == q3 && q3 != q4
  })
  |> iterator.take(5)
  |> iterator.each(fn(positions) {
    positions
    |> list.fold(empty_grid, place_robot_in_grid)
    |> list.map(string.join(_, ""))
    |> string.join("\n") 
    |> io.println

    io.println("\n")
  })
  
  "Not Implemented"
}
