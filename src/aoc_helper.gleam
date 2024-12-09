import gleam/iterator
import gleeunit/should
import gleam/bool
import gleam/list
import gleam/string
import day8
import day7
import gleam/result
import gleam/int
import gleam/float
import birl/duration
import birl
import argv
import day1
import day2
import day3
import day4
import day5
import day6
import dot_env as dot
import dot_env/env
import gleam/hackney
import gleam/http/request
import gleam/io
import simplifile as file
import gleam/erlang

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
    "6", "1" -> day6.part1(challenge_input)
    "6", "2" -> day6.part2(challenge_input)
    "7", "1" -> day7.part1(challenge_input)
    "7", "2" -> day7.part2(challenge_input)
    "8", "1" -> day8.part1(challenge_input)
    "8", "2" -> day8.part2(challenge_input)
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

  let aoc_year = "2024"

  case argv.load().arguments {
    ["start", day] -> {
      let source_file_path = "src/day"<>day<>".gleam"

      use <- bool.guard(result.unwrap(file.is_file(source_file_path), True), Nil)

      let assert Ok(source_template) = file.read("day_template.gleam")

      file.create_file(source_file_path)
      |> should.equal(Ok(Nil))

      file.write(source_file_path, source_template)
      |> should.equal(Ok(Nil))

    }
    ["add-test", day, part] -> {
      let test_file_path = "test/day"<>day<>"_test.gleam"

      use <- bool.guard(result.unwrap(file.is_file(test_file_path), True), Nil)
      
      let expected = erlang.get_line("What is the expected value (single line)>") |> result.unwrap("") |> string.trim
      io.println("What is the input (multiline, finish with an empty line)>")

      let multiline_input = 
      iterator.repeatedly(fn() {
        erlang.get_line("")
        |> result.unwrap("")
        |> string.trim
      })
      |> iterator.take_while(fn(a) { a |> string.is_empty |> bool.negate })
      |> iterator.to_list
      |> list.map(fn(line) { "    \""<>line<>"\","})

      let source_code = [
        [
          "import day"<>day,
          "import gleam/string",
          "import gleeunit/should",
          "",
          "pub fn part"<>part<>"_sample_text_test() {",
          "  ["
        ],
        multiline_input,
        [
          "  ]",
          "  |> string.join(\"\\n\")",
          "  |> day"<>day<>".part"<>part<>"()",
          "  |> should.equal(\""<>expected<>"\")",
          "}"
        ]
      ]
      |> list.flatten
      |> string.join("\n")

      file.create_file(test_file_path)
      |> should.equal(Ok(Nil))

      file.write(test_file_path, source_code)
      |> should.equal(Ok(Nil))
    }
    ["submit", day, part] -> {
      let challenge_input = get_users_challenge_input(aoc_year, day) 

      let before_run = birl.now() 
      let challenge_guess = do_challenge(day, part, challenge_input)
      let execution_time = birl.difference(birl.now(), before_run) |> duration.blur_to(duration.MicroSecond) 
        |> int.to_float 
        |> float.divide(1_000_000.0) 
        |> result.map(float.to_string)
        |> result.unwrap("unknown")
      
      io.println("Solving Day " <> day <> " part " <> part <> " took: " <> execution_time)
      io.println("Challenge output for day " <> day <> ": " <> challenge_guess)

      case erlang.get_line("Was this answer correct (y/n)? (A test will automatically be generated): ") == Ok("y\n") {
        True -> { let assert Ok(Nil) = add_test_matches_website(aoc_year, day, part, challenge_guess) Nil }
        False -> { Nil }
      }
    }
    _ -> panic as "That command is not supported!"
  }
}

pub fn get_users_challenge_input(year: String, day: String) {
    let input_file_name = "challenge_input/day" <> day <> ".txt"

    let challenge_input: String = case file.is_file(input_file_name) {
      Ok(True) -> {
        let assert Ok(challenge_input) = file.read(input_file_name)

        challenge_input
      }
      Ok(False) -> {
        let challenge_input = fetch_input(year, day)

        let assert Ok(Nil) = file.create_file(input_file_name)
        let assert Ok(Nil) = file.write(input_file_name, challenge_input)

        challenge_input
      }
      _ -> panic as "Give me permission to read your input file!!!"
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

fn add_test_matches_website(year: String, day: String, part: String, answer: String) -> Result(Nil, String) {
  let test_file_name = "test/day" <> day <> "_test.gleam"
  
  let imports = [ 
    "import day"<>day,
    "import aoc_helper",
    "import gleeunit/should"
  ]

  let test_source = [
    "pub fn day"<>day<>"_part"<>part<>"_on_full_input_test() {",
    "  aoc_helper.get_users_challenge_input(\""<>year<>"\", \""<>day<>"\")",
    "  |> day"<>day<>".part"<>part<>"()",
    "  |> should.equal(\""<>answer<>"\")",
    "}"
  ]
  |> string.join("\n")

  case file.is_directory("test") {
    Error(_) -> Error("Could not find a test directory! Are you running this from within the project?")
    Ok(_) -> {
      case file.is_file(test_file_name) {
        Error(_) | Ok(False) -> {
          let source_code = { imports |> string.join("\n") } <> "\n\n" <> test_source
          
          let create_and_write_file = fn() {
            use _ <- result.try(file.create_file(test_file_name))
            use _ <- result.try(file.write(test_file_name, source_code))
            Ok(Nil)
          }

          create_and_write_file() |> result.map_error(fn(_) { "Failed to create a file at: " <> test_file_name })
        }
        Ok(True) -> { 
          let assert Ok(existing_test_content) = file.read(test_file_name)

          let file_contains_test = string.contains(existing_test_content, "pub fn day"<>day<>"_part"<>part<>"_on_full_input_test") 
          use <- bool.guard(file_contains_test, Ok(Nil))

          imports
          |> list.filter(fn(line) { !string.contains(existing_test_content, line) })
          |> list.append([existing_test_content, test_source])
          |> string.join("\n")
          |> file.write(test_file_name, _)
          |> should.equal(Ok(Nil)) 

          Ok(Nil)
        }
      }
    }
  }
}
