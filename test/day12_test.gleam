import aoc_helper
import day12
import gleam/string
import gleeunit/should


pub fn part_1_sample_text_test() {
  [
    "RRRRIICCFF",
    "RRRRIICCCF",
    "VVRRRCCFFF",
    "VVRCCCJFFF",
    "VVVVCJJCFE",
    "VVIVCCJJEE",
    "VVIIICJJEE",
    "MIIIIIJJEE",
    "MIIISIJEEE",
    "MMMISSJEEE",
  ]
  |> string.join("\n")
  |> day12.part1
  |> should.equal("1930")
}

pub fn part_1_sample_text2_test() {
  [
    "AAAA",
    "BBCD",
    "BBCC",
    "EEEC",
  ]
  |> string.join("\n")
  |> day12.part1
  |> should.equal("140")
}



pub fn part1_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "12")
  |> day12.part1
  |> should.equal("1467094")
}