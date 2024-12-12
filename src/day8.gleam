import gleam/io
import gleam/string
import gleam/list
import gleam/dict.{type Dict}

fn enumerate(l: List(a)) -> List(#(Int, a)) { l |> list.index_map(fn(x, i) { #(i, x)}) }

pub fn parse(input: String) -> Dict(String, List(#(Int, Int))) {
  input
  |> string.split("\n")
  |> enumerate
  |> list.flat_map(fn(indexed_line) { 
    let #(row, line) = indexed_line

    line 
    |> string.split("")
    |> list.filter(fn(c) { c != "." }) 
    |> list.index_map(fn(c, col) { #(c, #(col, row)) })
  })
  |> list.group(fn(a) { a.0 })
  |> dict.map_values(fn(_, l: List(#(String, #(Int, Int)))) { 
    l |> list.map(fn(a) { a.1 }
  )})
}



fn generate_resonances(starting_emitter: #(Int, Int), other_emitters: List(#(Int, Int), grid_size: #(Int, Int))) -> List(#(Int, Int)) {
  other_emitters
  |> list.map(fn(a) { #(starting_emitter.0 - a.0, starting_emitter.1 - a.1) }) 

}

pub fn part1(challenge_input: String) -> String {
  parse(challenge_input)
  |> io.debug

  "Not Implemented"
}

pub fn part2(challenge_input: String) -> String {
  "Not Implemented"
}
