import argv
import day1
import day2
import day3
import day4
import day5
import dot_env as dot
import dot_env/env
import gleam/hackney
import gleam/http/request
import gleam/io
import simplifile as file

const aoc_url: String = "https://adventofcode.com/"

pub fn do_challenge(
  challenge_day: String,
  challenge_part: String,
  challenge_input: String,
) -> String {
  case challenge_day, challenge_part {
    "1", "1" -> day1.part1(challenge_input)
    "1", "2" -> day1.part2(challenge_input)
    "2", "1" -> day2.part1(challenge_input)
    "2", "2" -> day2.part2(challenge_input)
    "3", "1" -> day3.part1(challenge_input)
    "3", "2" -> day3.part2(challenge_input)
    "4", "1" -> day4.part1(challenge_input)
    "4", "2" -> day4.part2(challenge_input)
    "5", "1" -> day5.part1(challenge_input)
    "5", "2" -> day5.part2(challenge_input)
    _, _ -> {
      let panic_message =
        "No solution found for day " <> challenge_day <> "'s challenge"
      panic as panic_message
    }
  }
}

pub fn main() {
  dot.new()
  |> dot.set_debug(False)
  |> dot.load

  let aoc_year = "2022"

  case argv.load().arguments {
    ["submit", day, part] -> {
      let input_file_name = "challenge_input/day" <> day <> ".txt"

      let challenge_input: String = case file.is_file(input_file_name) {
        Ok(True) -> {
          let assert Ok(challenge_input) = file.read(input_file_name)

          challenge_input
        }
        Ok(False) -> {
          let challenge_input = fetch_input(aoc_year, day)

          let assert Ok(Nil) = file.create_file(input_file_name)
          let assert Ok(Nil) = file.write(input_file_name, challenge_input)

          challenge_input
        }
        _ -> panic as "Give me permission to read your input file!!!"
      }

      let challenge_guess = do_challenge(day, part, challenge_input)

      io.println("Challenge output for day " <> day <> ": " <> challenge_guess)
    }
    _ -> panic as "That command is not supported!"
  }
}

fn fetch_input(year: String, day: String) -> String {
  let assert Ok(input_file_request) =
    request.to(aoc_url <> year <> "/day/" <> day <> "/input")

  let assert Ok(session_token) = env.get_string("AOC_SESSION")

  let assert Ok(input_response) =
    input_file_request
    |> request.set_cookie("session", session_token)
    |> hackney.send

  io.println("sent the request")

  input_response.body
}
