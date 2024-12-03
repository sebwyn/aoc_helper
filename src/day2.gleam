import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

fn do_part1(arr: List(Int), asc: Option(Bool), mistake_count: Int) -> Int {
  case arr, asc {
    [_], _ | [], _ -> mistake_count
    [a, b, ..rst], None if 1 <= a - b && a - b <= 3 || 1 <= b - a && b - a <= 3 ->
      do_part1(list.flatten([[b], rst]), Some(a < b), mistake_count)
    [a, b, ..rst], Some(False) if a > b && 1 <= a - b && a - b <= 3 ->
      do_part1(list.flatten([[b], rst]), Some(False), mistake_count)
    [a, b, ..rst], Some(True) if a < b && 1 <= b - a && b - a <= 3 ->
      do_part1(list.flatten([[b], rst]), Some(True), mistake_count)
    [_, b, ..rst], asc ->
      do_part1(list.flatten([[b], rst]), asc, mistake_count + 1)
  }
}

pub fn part1(challenge_input: String) -> String {
  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { !string.is_empty(a) })
  |> list.map(fn(l) {
    string.split(l, " ")
    |> list.map(int.parse)
    |> result.values()
  })
  |> list.filter(fn(a) { do_part1(a, option.None, 0) == 0 })
  |> list.length
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { !string.is_empty(a) })
  |> list.map(fn(l) {
    string.split(l, " ")
    |> list.map(int.parse)
    |> result.values()
  })
  |> list.filter(fn(a) { do_part1(a, option.None, 0) < 2 })
  |> list.length
  |> int.to_string
}
