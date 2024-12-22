import day9
import gleam/string
import gleeunit/should


pub fn part_1_sample_text_test() {
  [
    "2333133121414131402",
  ]
  |> string.join("\n")
  |> day9.part1
  |> should.equal("1928")
}
