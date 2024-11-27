import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn part1(challenge_input: String) -> String {
  let points_for_result = fn(opp, me) -> Int {
    case opp, me {
      "A", "Y" | "B", "Z" | "C", "X" -> 6
      "A", "X" | "B", "Y" | "C", "Z" -> 3
      _, _ -> 0
    }
  }

  let points_for_choice = fn(choice) -> Int {
    case choice {
      "X" -> 1
      "Y" -> 2
      "Z" -> 3
      _ -> panic as "That isn't something I would choose"
    }
  }

  string.split(challenge_input, "\n")
  |> list.map(fn(game) {
    string.split_once(game, " ")
    |> result.map(fn(choices) {
      points_for_result(choices.0, choices.1) + points_for_choice(choices.1)
    })
    |> result.unwrap(0)
  })
  |> int.sum
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  let points_for_choice = fn(opp_choice, result) -> Int {
    case opp_choice, result {
      "A", "X" | "B", "Z" | "C", "Y" -> 3
      "C", "X" | "A", "Z" | "B", "Y" -> 2
      "B", "X" | "C", "Z" | "A", "Y" -> 1
      _, _ -> panic as "Impossible"
    }
  }

  let points_for_result = fn(result) -> Int {
    case result {
      "Z" -> 6
      "Y" -> 3
      "X" -> 0
      _ -> panic as "Impossible"
    }
  }

  string.split(challenge_input, "\n")
  |> list.map(fn(game) {
    string.split_once(game, " ")
    |> result.map(fn(choices) {
      points_for_result(choices.1) + points_for_choice(choices.0, choices.1)
    })
    |> result.unwrap(0)
  })
  |> int.sum
  |> int.to_string
}
