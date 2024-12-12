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