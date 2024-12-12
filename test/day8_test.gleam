import aoc_helper
import day8
import gleam/string
import gleeunit/should


pub fn part_1_sample_text_test() {
  [
    "............",
    "........0...",
    ".....0......",
    ".......0....",
    "....0.......",
    "......A.....",
    "............",
    "............",
    "........A...",
    ".........A..",
    "............",
    "............",
  ]
  |> string.join("\n")
  |> day8.part1
  |> should.equal("14")
}


pub fn part_2_sample_text_test() {
  [
    "............",
    "........0...",
    ".....0......",
    ".......0....",
    "....0.......",
    "......A.....",
    "............",
    "............",
    "........A...",
    ".........A..",
    "............",
    "............",
  ]
  |> string.join("\n")
  |> day8.part2
  |> should.equal("34")
}


pub fn part1_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "8")
  |> day8.part1
  |> should.equal("361")
}



pub fn part2_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "8")
  |> day8.part2
  |> should.equal("1249")
}