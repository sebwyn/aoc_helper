import gleam/bool
import gleam/int
import gleam/list
import gleam/option
import gleam/regex
import gleam/result
import gleam/string

pub fn part1(challenge_input: String) -> String {
  let range_is_fully_contained = fn(a: Int, b: Int, c: Int, d: Int) {
    { a <= c && d <= b } || { c <= a && b <= d }
  }

  let assert Ok(reg) =
    regex.compile(
      "(\\d+)-(\\d+),(\\d+)-(\\d+)",
      regex.Options(case_insensitive: True, multi_line: False),
    )

  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { !string.is_empty(a) })
  |> list.map(fn(pairs) {
    let assert Ok(match) =
      regex.scan(reg, pairs)
      |> list.first

    let assert Ok([r1_start, r1_end, r2_start, r2_end]) =
      match.submatches
      |> list.filter_map(option.to_result(_, Nil))
      |> list.map(int.parse)
      |> result.all

    range_is_fully_contained(r1_start, r1_end, r2_start, r2_end)
    |> bool.to_int
  })
  |> int.sum
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  let range_overlaps = fn(a: Int, b: Int, c: Int, d: Int) {
    { a <= c && c <= b }
    || { a <= d && d <= b }
    || { c <= a && a <= d }
    || { c <= b && b <= d }
  }

  let assert Ok(reg) =
    regex.compile(
      "(\\d+)-(\\d+),(\\d+)-(\\d+)",
      regex.Options(case_insensitive: True, multi_line: False),
    )

  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { !string.is_empty(a) })
  |> list.map(fn(pairs) {
    let assert Ok(match) =
      regex.scan(reg, pairs)
      |> list.first

    let assert Ok([r1_start, r1_end, r2_start, r2_end]) =
      match.submatches
      |> list.filter_map(option.to_result(_, Nil))
      |> list.map(int.parse)
      |> result.all

    range_overlaps(r1_start, r1_end, r2_start, r2_end)
    |> bool.to_int
  })
  |> int.sum
  |> int.to_string
}
