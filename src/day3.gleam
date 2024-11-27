import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string

fn calculate_priority(codepoint: UtfCodepoint) {
  case string.utf_codepoint_to_int(codepoint) {
    //lowercase
    a if a > 0x61 -> a - 0x60
    //capital
    b -> b - 0x40 + 26
  }
}

pub fn part1(challenge_input: String) -> String {
  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { !string.is_empty(a) })
  |> list.map(fn(items) {
    let #(first_compartment, second_compartment) =
      list.split(string.to_utf_codepoints(items), string.length(items) / 2)

    let assert [shared_type] =
      set.intersection(
        set.from_list(first_compartment),
        set.from_list(second_compartment),
      )
      |> set.to_list

    calculate_priority(shared_type)
  })
  |> int.sum
  |> int.to_string
}

pub fn part2(challenge_input: String) -> String {
  string.split(challenge_input, "\n")
  |> list.filter(fn(a) { !string.is_empty(a) })
  |> do_part2(0)
  |> int.to_string
}

fn do_part2(rucksacks: List(String), priority_acc: Int) {
  case rucksacks {
    [] -> priority_acc
    [rucksack_a, rucksack_b, rucksack_c, ..rest] -> {
      let assert Ok([common_between_all]) =
        [rucksack_a, rucksack_b, rucksack_c]
        |> list.map(fn(rucksack) {
          rucksack |> string.to_utf_codepoints |> set.from_list
        })
        |> list.reduce(set.intersection)
        |> result.map(set.to_list)

      do_part2(rest, priority_acc + calculate_priority(common_between_all))
    }
    _ -> panic as "Input is not a multiple of 3???"
  }
}
