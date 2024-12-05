import gleam/dict
import gleam/result
import gleam/string
import gleam/list
import gleam/int
import gleam/option.{type Option, Some, None}

fn word_from_grid(grid: List(String), word_len: Int, pos: #(Int, Int), step: #(Int, Int)) -> Option(String) {
  do_word_from_grid(grid, word_len, pos, step, "")
}

fn do_word_from_grid(grid: List(String), word_len: Int, pos: #(Int, Int), step: #(Int, Int), word: String) -> Option(String) {
  case word_len > 0 {
    False -> Some(word)
    True -> {
      let maybe_row = grid
      |> fn(a) { list.zip(list.range(0, list.length(a)), a) }
      |> list.key_find(pos.1)

      case maybe_row {
        Error(_) -> None
        Ok(row) -> { 
          case string.slice(row, pos.0, 1), 0 <= pos.0, pos.0 < string.length(row) {
            "", _, _ -> None
            a, True, True -> do_word_from_grid(grid, word_len - 1, #(pos.0 + step.0, pos.1 + step.1), step, word <> a)
            _, _, _ -> None
          }
        }
      }
    }
  }
}

fn print_to_grid(grid: List(String), word: String, pos: #(Int, Int), step: #(Int, Int)) -> Result(List(String), Nil) {
  case string.first(word) {
    Error(_) -> Ok(grid)
    Ok(c) -> {
      let #(rows_before, rows_after) = list.split(grid, pos.1)
      case rows_after {
        [] -> Error(Nil)
        [row, ..rows_after] -> {
          let before = string.slice(row, 0, pos.0)
          let after = string.slice(row, pos.0+1, string.length(row)-{pos.0+1})
          
          list.flatten([rows_before, [before <> c <> after], rows_after]) 
          |> print_to_grid(string.drop_start(word,1), #(pos.0+step.0,pos.1+step.1), step)
        }
      }

    }
  }
}

fn find_all_words_in_grid(grid: List(String), word: String, directions: List(#(Int, Int))) {
  let first_char = result.unwrap(string.first(word), "")
  let word_len = string.length(word)

  grid
  |> list.index_map(fn(x, i) { 
    string.split(x, "")
    |> fn(a) { list.zip(list.range(0, list.length(a)), a) }
    |> list.filter_map(fn(index_c) { 
      case index_c.1 == first_char {
        True -> Ok(#(index_c.0, i))
        False -> Error(Nil)
      }
    }) 
  })
  |> list.flatten 
  |> list.flat_map(fn(start_pos) { directions |> list.map(fn(step) { #(word_from_grid(grid, word_len, start_pos, step), start_pos, step) }) })
  |> list.filter(fn(a) { a.0 == Some(word) })
}

pub fn part1(challenge_input: String) -> String {
  let grid = string.split(challenge_input, "\n") |> list.filter(fn(a) { ! string.is_empty(a) })
  let word = "XMAS"
  let steps = [#(-1, -1), #(0, -1),  #(1, -1), 
               #(-1,  0),            #(1,  0), 
               #(-1,  1), #(0,  1),  #(1,  1)]

  find_all_words_in_grid(grid, word, steps)
  |> list.length
  |> int.to_string 

}

pub fn part2(challenge_input: String) -> String {
  let grid = string.split(challenge_input, "\n") |> list.filter(fn(a) { ! string.is_empty(a) })
  let word = "MAS"
  let steps = [#(-1, -1), #(1, -1), 
               #(-1,  1), #(1,  1)]

  find_all_words_in_grid(grid, word, steps)
  |> list.map(fn(tup) { #(tup.1.0 + tup.2.0, tup.1.1 + tup.2.1)})
  |> list.group(fn(a) { int.to_string(a.0) <> "_" <> int.to_string(a.1) } )
  |> dict.filter(fn(_, b) { list.length(b) == 2 })
  |> dict.size()
  |> int.to_string 

}
