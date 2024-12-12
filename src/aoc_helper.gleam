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

fn read_env() {
  dot.new()
  |> dot.set_debug(False)
  |> dot.load
}

fn get_multiline_input(prompt: String) -> List(String) {
  io.println(prompt)
  iterator.repeatedly(fn() {
    erlang.get_line("")
    |> result.unwrap("")
    |> string.trim
  })
  |> iterator.take_while(fn(a) { !string.is_empty(a) })
  |> iterator.to_list
}

pub fn main() {
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
      let test_file = "test/day"<>day<>"_test.gleam"
      let test_name = "part_"<>part<>"_sample_text_test"

      let imports = [
        "import day"<>day,
        "import gleam/string",
        "import gleeunit/should",
      ]

      let input = get_multiline_input("What is the input (multiline, finish with an empty line)>")
        |> list.map(fn(line) { "  \""<>line<>"\","})
      let input_code = [ ["["], input, ["]", "|> string.join(\"\\n\")"] ] |> list.flatten
      let production_call = "day"<>day<>".part"<>part
      let expected = "\""<>{erlang.get_line("What is the expected value (single line)>") |> result.unwrap("") |> string.trim}<>"\""

      test_file 
      |> add_gleam_test(test_name, imports, input_code, production_call, expected)
      |> should.equal(Ok(Nil))

      Nil
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
  read_env()

  let input_file_name = "challenge_input/day" <> day <> ".txt"

  case file.is_file(input_file_name) {
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
  let test_file = "test/day" <> day <> "_test.gleam"
  
  let test_name = "part"<>part<>"_on_full_input_test"

  let imports = [ 
    "import day"<>day,
    "import aoc_helper",
    "import gleeunit/should"
  ]
  let input_lines = ["aoc_helper.get_users_challenge_input(\""<>year<>"\", \""<>day<>"\")"]
  let production_call = "day"<>day<>".part"<>part
  let expected_value = "\""<>answer<>"\""
  
  test_file
  |> add_gleam_test(test_name, imports, input_lines, production_call, expected_value)
}

fn add_gleam_test(
  test_file: String, 
  test_name: String, 
  imports: List(String), 
  input_code: List(String),
  production_call: String,
  expected_value: String
) {
  let test_source_code = 
    [
      "pub fn "<>test_name<>"() {", 
      input_code |> list.map(fn(i) { string.concat(["  ", i]) }) |> string.join("\n"),
      "  |> "<>production_call,
      "  |> should.equal("<>expected_value<>")",
      "}"
    ]
    |> string.join("\n")

  case file.is_file(test_file) {
    Error(_) | Ok(False) -> {
      let create_and_write_file = fn(file_name: String, content: String) {
        use _ <- result.try(file.create_file(file_name))
        use _ <- result.try(file.write(file_name, content))
        Ok(Nil)
      }

      imports
      |> list.append(["", "", test_source_code])
      |> string.join("\n")
      |> create_and_write_file(test_file, _)
      |> result.map_error(fn(_) { "Failed to create a file at: " <> test_file })
    }
    Ok(True) -> { 
      let assert Ok(existing_test_content) = file.read(test_file)

      let file_contains_test = string.contains(existing_test_content, "pub fn "<>test_name<>"() {") 
      use <- bool.guard(file_contains_test, Ok(Nil))

      let existing_imports = existing_test_content |> string.split("\n") 
        |> list.take_while(fn(a) { string.starts_with(a, "import") })
        |> string.join("\n")
      
      let existing_code = existing_test_content |> string.split("\n") 
        |> list.drop_while(fn(a) { string.starts_with(a, "import") || string.is_empty(a) })
        |> string.join("\n")

      imports
      |> list.filter(fn(new) { existing_imports |> string.contains(new) |> bool.negate })
      |> list.append([existing_imports, "", "", existing_code, "", "", test_source_code])
      |> string.join("\n")
      |> file.write(test_file, _)
      |> result.map_error(fn(_) { "Failed to write a file at: " <> test_file })
    }
  }
}

