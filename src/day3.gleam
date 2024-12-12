import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regex
import gleam/result

pub fn part1(challenge_input: String) -> String {
  let assert Ok(re) =
    regex.compile("mul\\((\\d{1,3}),(\\d{1,3})\\)", regex.Options(True, True))
  regex.scan(re, challenge_input)
  |> list.map(fn(a) {
    case a.submatches {
      [Some(a), Some(b)] ->
        result.unwrap(int.parse(a), 0) * result.unwrap(int.parse(b), 0)
      _ -> 0
    }
  })
  |> int.sum
  |> int.to_string
}

type Funcs {
  Do
  DoNot
  Value(Int)
}

fn do_sum(funcs: List(Funcs), mul_enabled: Int, acc: Int) -> Int {
  case funcs {
    [] -> acc
    [Do, ..r] -> do_sum(r, 1, acc)
    [DoNot, ..r] -> do_sum(r, 0, acc)
    [Value(a), ..r] -> do_sum(r, mul_enabled, acc + mul_enabled * a)
  }
}

pub fn part2(challenge_input: String) -> String {
  let assert Ok(re) =
    regex.compile(
      "mul\\((\\d{1,3}),(\\d{1,3})\\)|do\\(\\)|don't\\(\\)",
      regex.Options(True, True),
    )
  regex.scan(re, challenge_input)
  |> list.map(fn(a) {
    case a {
      regex.Match("do()", ..) -> Do
      regex.Match("don't()", ..) -> DoNot
      regex.Match(_, [Some(a), Some(b)]) ->
        Value(
          { a |> int.parse |> result.unwrap(0) }
          * { b |> int.parse |> result.unwrap(0) },
        )
      _ -> panic as "The regex should not land in this case"
    }
  })
  |> do_sum(1, 0)
  |> int.to_string
}
