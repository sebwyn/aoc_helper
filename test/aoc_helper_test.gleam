import day6
import day5
import gleam/list
import gleam/io
import day2
import day4
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn day2_test() {
  [
    [7,6,4,2,1],
    [1,2,7,8,9],
    [9,7,6,2,1],
    [1,3,2,4,5],
    [8,6,4,4,1],
    [1,3,6,7,9]
  ]
  |> list.count(day2.is_valid_with_one_mistake)
  |> should.equal(4)
}

pub fn day5_test() {
  let challenge_input = 
"47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"

    day5.part1(challenge_input)
    |> should.equal("143")
}


pub fn day6_test() {
  let input = 
"....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

    day6.part2(input)
    |> should.equal("6")
}
