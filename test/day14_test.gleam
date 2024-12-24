import day14
import aoc_helper
import gleeunit/should


pub fn part1_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "14")
  |> day14.part1
  |> should.equal("222062148")
}