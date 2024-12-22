import gleam/result
import gleam/int
import gleam/string
import gleam/list

fn parse(input: String) -> Result(List(Int), Nil) {
  use first_line <- result.try(input |> string.split("\n") |> list.first)
  first_line |> string.split("") |> list.try_map(int.parse)
}

pub fn part1(challenge_input: String) -> String {
  let assert Ok(file_structure) = parse(challenge_input)
  list.window_by_2(file_structure)
  |> list.index_fold("", fn(acc, spec, i) { acc <> string.repeat(int.to_string(i), spec.0) <> string.repeat(".", spec.1)} )
}

pub fn part2(challenge_input: String) -> String {
  "Not Implemented"
}
