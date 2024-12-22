import aoc_helper
import day11
import gleam/string
import gleeunit/should


pub fn part_1_sample_text_test() {
  [
    "125 17",
  ]
  |> string.join("\n")
  |> day11.part1
  |> should.equal("55312")
}


pub fn part1_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "11")
  |> day11.part1
  |> should.equal("194557")
}

pub fn part2_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "11")
  |> day11.part2
  |> should.equal("231532558973909")
}
