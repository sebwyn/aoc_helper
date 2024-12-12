import gleam/set
import gleam/result
import gleam/iterator
import gleam/int
import gleam/io
import gleam/string
import gleam/list
import gleam/dict.{type Dict}

fn enumerate(l: List(a)) -> List(#(Int, a)) { l |> list.index_map(fn(x, i) { #(i, x)}) }

pub fn parse(input: String) -> Result(#(Dict(String, List(#(Int, Int))), #(Int, Int)), Nil) {
  let lines = input |> string.split("\n")

  let emitters = lines
  |> enumerate
  |> list.flat_map(fn(indexed_line) { 
    let #(row, line) = indexed_line

    line 
    |> string.split("")
    |> enumerate
    |> list.filter(fn(c) { c.1 != "." }) 
    |> list.map(fn(c) { #(c.1, #(c.0, row)) })
  })
  |> list.group(fn(a) { a.0 })
  |> dict.map_values(fn(_, l) { l |> list.map(fn(a) { a.1 }) })

  use first_line <- result.try(list.first(lines))
  Ok(#(emitters, #(list.length(lines), string.length(first_line))))
}

fn generate_resonance(starting_emitter: #(Int, Int), other_emitter: #(Int, Int)) -> #(Int, Int) {
  #(starting_emitter.0 + { {other_emitter.0 - starting_emitter.0} * 2 }, starting_emitter.1 + { {other_emitter.1 - starting_emitter.1} * 2 }) 
}

fn generate_all_resonances(emitters: List(#(Int, Int))) -> List(#(Int, Int)) {
  list.range(0, list.length(emitters) - 1)
  |> list.flat_map(fn(i) { 
    let emitters_prev = list.take(emitters, i)
    let assert [emitter, ..emitters_rest] = list.drop(emitters, i)
    
    io.debug(#(emitter, list.flatten([emitters_prev, emitters_rest])))

    list.flatten([emitters_prev, emitters_rest])
    |> list.map(generate_resonance(emitter, _))
  })
}


pub fn part1(challenge_input: String) -> String {
  let assert Ok(#(emitters, grid_size)) = parse(challenge_input)

  emitters
  |> io.debug
  |> dict.values()
  |> list.flat_map(fn(emitters) { 
    let emitters_s = emitters |> set.from_list() 
    generate_all_resonances(emitters) |> list.filter(fn(r) { !set.contains(emitters_s, r) }) 
  })
  |> list.unique
  |> list.filter(fn(xy) { 0 <= xy.0 && xy.0 < grid_size.0 && 0 <= xy.1 && xy.1 < grid_size.1 })
  |> list.length
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  "Not Implemented"
}
