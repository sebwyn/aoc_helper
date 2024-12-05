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

pub fn day4_test() {
  let challenge_input = 
    "MMMSXXMASM" <> "\n" <>
    "MSAMXMSMSA" <> "\n" <>
    "AMXSXMAAMM" <> "\n" <>
    "MSAMASMSMX" <> "\n" <>
    "XMASAMXAMM" <> "\n" <>
    "XXAMMXXAMA" <> "\n" <>
    "SMSMSASXSS" <> "\n" <>
    "SAXAMASAAA" <> "\n" <>
    "MAMMMXMMMM" <> "\n" <>
    "MXMXAXMASX" <> "\n" 

  let expected_output = 
    "....XXMAS." <> "\n" <>
    ".SAMXMS..." <> "\n" <>
    "...S..A..." <> "\n" <>
    "..A.A.MS.X" <> "\n" <>
    "XMASAMX.MM" <> "\n" <>
    "X.....XA.A" <> "\n" <>
    "S.S.S.S.SS" <> "\n" <>
    ".A.A.A.A.A" <> "\n" <>
    "..M.M.M.MM" <> "\n" <>
    ".X.X.XMASX" <> "\n"

  let actual = day4.part1(challenge_input)
  io.println(actual)
  actual |> should.equal(expected_output)

}
