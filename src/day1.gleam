import gleam/dict
import gleam/function
import gleam/int
import gleam/result
import gleam/list
import gleam/string

fn parse(input: String) -> #(List(Int), List(Int)) {
  let #(col1, col2) = 
    string.split(input, "\n")
    |> list.filter_map(fn(line) { 
      use nums <- result.try(string.split_once(line, "   "))
      use num1 <- result.try(int.parse(nums.0))
      use num2 <- result.try(int.parse(nums.1))
      Ok(#(num1, num2))
    })
    |> list.unzip 
  
  let col1 = list.sort(col1, int.compare)
  let col2 = list.sort(col2, int.compare)

  #(col1, col2)
}

pub fn part1(challenge_input: String) -> String {
  let #(col1, col2) = parse(challenge_input)

  list.zip(col1, col2)
  |> list.map(fn(cols) { cols.1 - cols.0 |> int.absolute_value })
  |> int.sum
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  let #(col1, col2) = parse(challenge_input)
  
  let counts = list.group(col2, function.identity) |> dict.map_values(fn(_, val) { list.length(val) })

  list.map(col1, fn(val) { 
    dict.get(counts, val) |> result.unwrap(0) |> int.multiply(val) })
  |> int.sum 
  |> int.to_string 
}
