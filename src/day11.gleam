import gleam/option
import gleam/dict
import gleam/iterator
import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn parse(input: String) -> Result(List(Int), Nil) {
  input
  |> string.split("\n")
  |> list.first
  |> result.try(fn(a) { a|> string.split(" ") |> list.try_map(int.parse) })
}

fn find_places(num: Int) -> Int {
  iterator.iterate(num, fn(a) { a / 10 })
  |> iterator.index
  |> iterator.find_map(fn(a_i) { 
    case a_i.0 {
      0 -> Ok(a_i.1)
      _ -> Error(Nil) 
    }
  })
  |> result.unwrap(0)
}

fn blink_single(num: Int) -> List(Int) {
  let places = find_places(num)
  case num, places {
    0, _ -> [1]
    _, l if l % 2 == 0 -> { 
      let half_place_value = iterator.repeat(10) 
        |> iterator.take(places / 2) 
        |> iterator.reduce(int.multiply) 
        |> result.unwrap(1)
      
      [num / half_place_value, num % half_place_value]
    }
    i, _ -> [i*2024]
  }
}

fn blink(input: List(Int)) -> List(Int) {
  input
  |> list.flat_map(blink_single)
}

pub fn part1(challenge_input: String) -> String {
  let assert Ok(starting_state) = challenge_input |> parse
  
  iterator.iterate(0, int.add(_, 1)) |> iterator.take(25)
  |> iterator.fold(starting_state, fn(state, _) { blink(state) })
  |> list.length
  |> int.to_string
}

fn blink_memoized(state: List(#(Int, Int))) -> List(#(Int, Int)) {
    state
    |> list.flat_map(fn(state_multiplier) {
      let #(state, multiplier) = state_multiplier
      state
      |> blink_single
      |> iterator.from_list
      |> iterator.zip(iterator.repeat(multiplier))
      |> iterator.to_list
    })
    |> list.fold(dict.new(), fn(d, state_multiplier) { 
      let #(state, multiplier) = state_multiplier
      dict.upsert(d, state, fn(existing) {
        case existing {
          option.None -> multiplier
          option.Some(v) -> v + multiplier
        }
      })
    })
    |> dict.to_list
}

pub fn part2(challenge_input: String) -> String {
  let assert Ok(starting_state) = challenge_input |> parse
  
  let starting_state = iterator.from_list(starting_state)
  |> iterator.zip(iterator.repeat(1))
  |> iterator.to_list()

  iterator.iterate(0, int.add(_, 1)) |> iterator.take(75)
  |> iterator.fold(starting_state, fn(state, _) { blink_memoized(state) })
  |> fn(a) { list.unzip(a).1 }
  |> int.sum 
  |> int.to_string
}
