import aoc_helper
import day10
import gleam/string
import gleeunit/should


pub fn part_1_sample_text_test() {
  [
    "89010123",
    "78121874",
    "87430965",
    "96549874",
    "45678903",
    "32019012",
    "01329801",
    "10456732",
  ]
  |> string.join("\n")
  |> day10.part1
  |> should.equal("36")
}

pub fn part_1_sample_text2_test() {
  [
    "...0...",
    "...1...",
    "...2...",
    "6543456",
    "7.....7",
    "8.....8",
    "9.....9"
  ]
  |> string.join("\n")
  |> day10.part1
  |> should.equal("2")
}

pub fn part_1_sample_text3_test() {
  [
    "10..9..",
    "2...8..",
    "3...7..",
    "4567654",
    "...8..3",
    "...9..2",
    ".....01",
  ]
  |> string.join("\n")
  |> day10.part1
  |> should.equal("3")
}


pub fn part1_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "10")
  |> day10.part1
  |> should.equal("593")
}

pub fn part_2_sample_text_test() {
  [
    "89010123",
    "78121874",
    "87430965",
    "96549874",
    "45678903",
    "32019012",
    "01329801",
    "10456732",
  ]
  |> string.join("\n")
  |> day10.part2
  |> should.equal("81")
}


pub fn part2_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "10")
  |> day10.part2
  |> should.equal("1192")
}
