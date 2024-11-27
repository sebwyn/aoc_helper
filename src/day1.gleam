import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn part1(challenge_input: String) -> String {
  string.split(challenge_input, "\n\n")
  |> list.map(fn(input) {
    string.split(input, "\n")
    |> list.filter_map(int.parse)
    |> int.sum
  })
  |> list.reduce(int.max)
  |> result.map(int.to_string)
  |> result.unwrap("Failed to find a valid result!")
}

pub fn part2(challenge_input: String) -> String {
  string.split(challenge_input, "\n\n")
  |> list.map(fn(input) {
    string.split(input, "\n")
    |> list.filter_map(int.parse)
    |> int.sum
  })
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> int.sum
  |> int.to_string
}
