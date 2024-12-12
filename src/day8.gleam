import gleam/result
import gleam/iterator
import gleam/int
import gleam/string
import gleam/list
import gleam/dict.{type Dict}

fn enumerate(l: List(a)) -> List(#(Int, a)) { l |> list.index_map(fn(x, i) { #(i, x)}) }

pub fn parse(input: String) -> Result(#(Dict(String, List(#(Int, Int))), #(Int, Int)), Nil) {
  let lines = input |> string.split("\n") |> list.filter(fn(a) { ! string.is_empty(a) })

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
  Ok(#(emitters, #(string.length(first_line), list.length(lines))))
}

fn generate_resonance(starting_emitter: #(Int, Int), other_emitter: #(Int, Int)) -> List(#(Int, Int)) {
  [#(starting_emitter.0 + { {other_emitter.0 - starting_emitter.0} * 2 }, starting_emitter.1 + { {other_emitter.1 - starting_emitter.1} * 2 })]
}

fn generate_many_resonances(grid_size: #(Int, Int), starting_emitter: #(Int, Int), other_emitter: #(Int, Int)) -> List(#(Int, Int)) {
  iterator.iterate(1, int.add(_, 1)) 
  |> iterator.map(fn(i) { #(starting_emitter.0 + { {other_emitter.0 - starting_emitter.0} * i }, starting_emitter.1 + { {other_emitter.1 - starting_emitter.1} * i }) })
  |> iterator.take_while(fn(xy) { 0 <= xy.0 && xy.0 < grid_size.0 && 0 <= xy.1 && xy.1 < grid_size.1 })
  |> iterator.to_list
}

fn generate_all_resonances(
  emitters: List(#(Int, Int)), 
  resonance_generator: fn(#(Int, Int), #(Int, Int)) -> List(#(Int, Int))
) -> List(#(Int, Int)) {
  list.range(0, list.length(emitters) - 1)
  |> list.flat_map(fn(i) { 
    let emitters_prev = list.take(emitters, i)
    let assert [emitter, ..emitters_rest] = list.drop(emitters, i)
    
    list.flatten([emitters_prev, emitters_rest])
    |> list.flat_map(resonance_generator(emitter, _))
  })
}


pub fn part1(challenge_input: String) -> String {
  let assert Ok(#(emitters, grid_size)) = parse(challenge_input)

  emitters
  |> dict.values()
  |> list.flat_map(generate_all_resonances(_, generate_resonance))
  |> list.unique
  |> list.filter(fn(xy) { 0 <= xy.0 && xy.0 < grid_size.0 && 0 <= xy.1 && xy.1 < grid_size.1 })
  |> list.length
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  let assert Ok(#(emitters, grid_size)) = parse(challenge_input)

  emitters
  |> dict.values()
  |> list.flat_map(generate_all_resonances(_, fn(a, b) { generate_many_resonances(grid_size, a, b) }))
  |> list.unique
  |> list.length
  |> int.to_string
}
