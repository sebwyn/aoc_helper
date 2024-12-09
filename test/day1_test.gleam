import day1
import aoc_helper
import gleeunit/should

pub fn day1_part1_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "1")
  |> day1.part1()
  |> should.equal("1197984")
}
pub fn day1_part2_on_full_input_test() {
  aoc_helper.get_users_challenge_input("2024", "1")
  |> day1.part2()
  |> should.equal("23387399")
}