import gleam/float
import gleam/result
import gleam/list
import gleam/string
import gleam/int

fn parse(challenge_input) -> Result(List(#(Int, List(Int))), Nil) {
  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { ! string.is_empty(a) })
  |> list.try_map(fn(line) {
    use #(test_value_s, operand_s) <- result.try(string.split_once(line, ":"))
    use test_value <- result.try(int.parse(test_value_s))
    use inputs <- result.try(
      operand_s
      |> string.trim 
      |> string.split(" ")
      |> list.try_map(int.parse)
    )
      
    Ok(#(test_value, inputs))
  })
}

fn i_power(a: Int, power: Int) -> Int {
  case int.power(a, int.to_float(power)) {
    Ok(val) -> float.round(val)
    Error(_) -> panic as "Why u gotta be failing me exponent"
  }
}

fn create_ordering(number_of_values: Int, number_of_elements: Int, counter: Int, ordering: List(Int)) -> List(Int) {
  case number_of_elements {
    0 -> ordering
    _ -> {
      let place_value = i_power(number_of_values, number_of_elements-1)
      create_ordering(number_of_values, number_of_elements - 1, counter % place_value, [counter / place_value, ..ordering])
    } 
  }
}

pub fn all_possible_orderings(number_of_values: Int, number_of_elements: Int) -> List(List(Int)) {
  list.range(0, i_power(number_of_values, number_of_elements) - 1)
  |> list.map(create_ordering(number_of_values, number_of_elements, _, []))
}

pub fn part1(challenge_input: String) -> String { 
  let assert Ok(equations) = parse(challenge_input)
 
  equations 
  |> list.filter(fn(a) { 
    let #(expected, operands) = a

    all_possible_orderings(2, list.length(operands) - 1)
    |> list.map(fn(ordering) {
      let operations = ordering 
      |> list.map(fn(o) { 
        case o {
          0 -> int.add
          1 -> int.multiply
          _ -> panic as "Unexpected value in ordering"
        }
      })
      
      case a.1 {
        [first, ..rest] -> list.fold(list.zip(rest, operations), first, fn(acc, a) { a.1(acc, a.0) })
        _ -> panic as "Gleam your killing me"
      }
    })
    |> list.any(fn(calculated) { calculated == expected })
  })
  |> list.map(fn(a) { a.0 })
  |> int.sum
  |> int.to_string
}

fn concatenate_ints(a: Int, b: Int) -> Int {
  case { int.to_string(a) <> int.to_string(b) } |> int.parse {
    Ok(a) -> a
    _ -> panic as "Never gonna happen"
  }
}

pub fn part2(challenge_input: String) -> String { 
  let assert Ok(equations) = parse(challenge_input)
 
  equations 
  |> list.filter(fn(a) { 
    let #(expected, operands) = a

    all_possible_orderings(3, list.length(operands) - 1)
    |> list.map(fn(ordering) {
      let operations = ordering 
      |> list.map(fn(o) { 
        case o {
          0 -> int.add
          1 -> int.multiply
          2 -> concatenate_ints
          _ -> panic as "Unexpected value in ordering"
        }
      })
      
      case a.1 {
        [first, ..rest] -> list.fold(list.zip(rest, operations), first, fn(acc, a) { a.1(acc, a.0) })
        _ -> panic as "Gleam your killing me"
      }
    })
    |> list.any(fn(calculated) { calculated == expected })
  })
  |> list.map(fn(a) { a.0 })
  |> int.sum
  |> int.to_string
}
