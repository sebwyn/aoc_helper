import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn do_is_valid(arr: List(Int), asc: Bool) -> Bool {
  case arr, asc {
    [_], _ | [], _ -> True
    [a, b, ..rst], False if a > b && 1 <= a - b && a - b <= 3 ->
      do_is_valid(list.flatten([[b], rst]), False)
    [a, b, ..rst], True if a < b && 1 <= b - a && b - a <= 3 ->
      do_is_valid(list.flatten([[b], rst]), True)
    _, _ -> False
  }
}

pub fn is_valid(arr: List(Int)) {
  do_is_valid(arr, True) || do_is_valid(arr, False)
}

pub fn is_valid_with_one_mistake(arr: List(Int)) -> Bool {
  list.range(0, list.length(arr) - 1)
  |> list.map(fn(index) { list.flatten([list.take(arr, index), list.drop(arr, index+1)]) })
  |> list.any(is_valid)
}

pub fn part1(challenge_input: String) -> String {
  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { !string.is_empty(a) })
  |> list.map(fn(l) { string.split(l, " ") |> list.map(int.parse) |> result.values() })
  |> list.count(is_valid)
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { !string.is_empty(a) })
  |> list.map(fn(l) { string.split(l, " ") |> list.map(int.parse) |> result.values() })
  |> list.count(is_valid_with_one_mistake)
  |> int.to_string
}
