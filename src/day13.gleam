import gleam/float
import gleam/int
import gleam/result
import gleam/list
import gleam/string
import gleam/regex
import gleam/option.{Some}

type ClawGame {
  ClawGame(a_button_delta: #(Int, Int), b_button_delta: #(Int, Int), prize: #(Int, Int))
}

fn parse(input: String) -> Result(List(ClawGame), Nil) {
  let assert Ok(button_a_regex) = regex.from_string("Button A: X\\+(\\d+), Y\\+(\\d+)")
  let assert Ok(button_b_regex) = regex.from_string("Button B: X\\+(\\d+), Y\\+(\\d+)")
  let assert Ok(prize_regex) = regex.from_string("Prize: X=(\\d+), Y=(\\d+)")

  input
  |> string.split("\n\n")
  |> list.try_map(fn(rules) {
    use a_match <- result.try(regex.scan(button_a_regex, rules) |> list.first)
    use b_match <- result.try(regex.scan(button_b_regex, rules) |> list.first)
    use prize_match <- result.try(regex.scan(prize_regex, rules) |> list.first)

    let assert [Some(a_button_x), Some(a_button_y)] = a_match.submatches
    let assert [Some(b_button_x), Some(b_button_y)] = b_match.submatches
    let assert [Some(prize_x), Some(prize_y)] = prize_match.submatches

    let assert Ok([a_button_x, a_button_y, b_button_x, b_button_y, prize_x, prize_y]) = 
      [a_button_x, a_button_y, b_button_x, b_button_y, prize_x, prize_y] 
      |> list.try_map(int.parse)
    
    Ok(ClawGame(#(a_button_x, a_button_y), #(b_button_x, b_button_y), #(prize_x, prize_y)))
  })
}

fn compute_presses_for_game(game: ClawGame) -> Result(#(Int, Int), Nil) {
  let b_button_inverse_slope = int.to_float(game.b_button_delta.0) /. int.to_float(game.b_button_delta.1)
  let a_presses_calculation_numerator = int.to_float(game.prize.0) -. b_button_inverse_slope *. int.to_float(game.prize.1)
  let a_presses_calculation_denominator = int.to_float(game.a_button_delta.0) -. b_button_inverse_slope *. int.to_float(game.a_button_delta.1)
  let a_button_presses = float.round(a_presses_calculation_numerator /. a_presses_calculation_denominator)

  let b_button_presses = { game.prize.0 - game.a_button_delta.0 * a_button_presses } / game.b_button_delta.0
  
  case 
    0 <= a_button_presses && 0 <= b_button_presses
    && { a_button_presses * game.a_button_delta.0 } + { b_button_presses * game.b_button_delta.0 } == game.prize.0
    && { a_button_presses * game.a_button_delta.1 } + { b_button_presses * game.b_button_delta.1 } == game.prize.1
  {
    True -> Ok(#(a_button_presses, b_button_presses))
    False -> Error(Nil)
  }
}

pub fn part1(challenge_input: String) -> String {
  let assert Ok(games) = parse(challenge_input)
  
  games
  |> list.filter_map(compute_presses_for_game)
  |> list.map(fn(a_b) { a_b.1 + 3 * a_b.0 })
  |> int.sum
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  let assert Ok(games) = parse(challenge_input)
  
  games
  |> list.map(fn(game) {
    let prize_x = 10000000000000 + game.prize.0
    let prize_y = 10000000000000 + game.prize.1
    ClawGame(..game, prize: #(prize_x, prize_y))
  })
  |> list.filter_map(compute_presses_for_game)
  |> list.map(fn(a_b) { a_b.1 + 3 * a_b.0 })
  |> int.sum
  |> int.to_string
}
