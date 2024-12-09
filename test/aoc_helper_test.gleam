import day7
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

pub fn day7_test() {
  day7.all_possible_orderings(2, 2)
  |> should.equal([[0, 0], [1, 0], [0, 1], [1, 1]])

  day7.all_possible_orderings(2, 3)
  |> should.equal([
    [0, 0, 0], [1, 0, 0], [0, 1, 0], [1, 1, 0],
    [0, 0, 1], [1, 0, 1], [0, 1, 1], [1, 1, 1]
  ])

  let input = 
"190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"

    day7.part1(input)
    |> should.equal("3749")
}
