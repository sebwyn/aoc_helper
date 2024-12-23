import aoc_helper
import day13
import gleam/string
import gleeunit/should


pub fn part_1_sample_text_test() {
  [
    "Button A: X+94, Y+34",
    "Button B: X+22, Y+67",
    "Prize: X=8400, Y=5400",
    "",
    "Button A: X+26, Y+66",
    "Button B: X+67, Y+21",
    "Prize: X=12748, Y=12176",
    "",
    "Button A: X+17, Y+86",
    "Button B: X+84, Y+37",
    "Prize: X=7870, Y=6450",
    "",
    "Button A: X+69, Y+23",
    "Button B: X+27, Y+71",
    "Prize: X=18641, Y=10279",
  ]
  |> string.join("\n")
  |> day13.part1
  |> should.equal("480")
}



pub fn part1_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "13")
  |> day13.part1
  |> should.equal("34787")
}


pub fn part2_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "13")
  |> day13.part2
  |> should.equal("85644161121698")
}