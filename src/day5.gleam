import gleam/set
import gleam/int
import gleam/option
import gleam/result
import gleam/list
import gleam/string
import gleam/dict.{type Dict}

pub fn parse_input(challenge_input: String) -> #(Dict(Int, set.Set(Int)), Dict(Int, set.Set(Int)), List(List(Int))) {
  let lines = string.split(challenge_input, "\n")
  
  let assert Ok(rules_list) = lines 
    |> list.take_while(fn(l) { !string.is_empty(l) })
    |> list.try_map(fn(line) { 
      use #(before, after) <- result.try(string.split_once(line, "|"))
      use before <- result.try(int.parse(before))
      use after <- result.try(int.parse(after))
      Ok(#(before, after))
    })

  let before_rules = rules_list 
    |> list.fold(dict.new(), fn(d, rule) { dict.upsert(d, rule.1, fn(l) { [ rule.0, ..option.unwrap(l, [])] }) }) 
    |> dict.map_values(fn(_, value) { value |> set.from_list })

  let after_rules = rules_list 
    |> list.fold(dict.new(), fn(d, rule) { dict.upsert(d, rule.0, fn(l) { [ rule.1, ..option.unwrap(l, [])] }) }) 
    |> dict.map_values(fn(_, value) { value |> set.from_list })

  let assert Ok(updates) = lines
  |> list.drop_while(fn(line) { string.contains(line, "|") || string.is_empty(line) })
  |> list.filter(fn(a) { ! string.is_empty(a) })
  |> list.try_map(fn(a) { string.split(a, ",") |> list.try_map(int.parse) }) 
  
  #(before_rules, after_rules, updates)
}

fn page_order_follows_rules(page_order: List(Int), rules: Dict(Int, set.Set(Int)), out_of_order_pages: set.Set(Int)) -> Bool {
  case page_order {
    [] -> True
    [page, ..remaining_pages] -> { 
      case out_of_order_pages |> set.contains(page) {
        True -> False
        False -> page_order_follows_rules(
          remaining_pages, 
          rules,
          dict.get(rules, page) |> result.unwrap(set.new()) |> set.union(out_of_order_pages)
        )
      }
    }
  } 
}

fn get_middle_element(l: List(a)) -> Result(a, Nil) {
  let list_length = list.length(l)
  let middle_index = list_length / 2
  
  l
  |> list.index_map(fn(x, i) { #(i, x) })
  |> list.find_map(fn(i_x) { case i_x.0 == middle_index {
    True -> Ok(i_x.1)
    _ -> Error(Nil)
  }})
}

pub fn part1(challenge_input: String) -> String {
  let #(before_rules, _, updates) = parse_input(challenge_input)

  updates
  |> list.filter(page_order_follows_rules(_, before_rules, set.new())) 
  |> list.try_map(get_middle_element)
  |> result.map(fn(a) { a |> int.sum |> int.to_string })
  |> result.unwrap("Could not find the middle element")
}

type Node {
  Empty
  Single(value: Int)
  Branching(value: Int, lower: Node, higher: Node)
}

fn visit_unordered_pages(pages: List(Int), before_rules: Dict(Int, set.Set(Int)), after_rules: Dict(Int, set.Set(Int))) -> Node {
  case pages {
    [] -> Empty  
    [page] -> Single(page)
    [page, ..rest] -> {
      let rest_set = rest |> set.from_list
      
      let apply_rules_and_build_tree = fn(remaining_pages, rules) { 
        remaining_pages
        |> set.intersection(rules)
        |> set.to_list
        |> visit_unordered_pages(before_rules, after_rules)  
      } 

      Branching(
        value: page, 
        lower: dict.get(before_rules, page) |> result.map(apply_rules_and_build_tree(rest_set, _)) |> result.unwrap(Empty),
        higher: dict.get(after_rules, page) |> result.map(apply_rules_and_build_tree(rest_set, _)) |> result.unwrap(Empty),
      )
    }

  }
}

fn build_list_from_tree(node: Node) -> List(Int) {
  case node {
    Empty -> []
    Single(value) -> [value]
    Branching(value, lower, higher) -> list.flatten([build_list_from_tree(lower), [value], build_list_from_tree(higher)])
  }
}

pub fn part2(challenge_input: String) -> String {
  let #(before_rules, after_rules, updates) = parse_input(challenge_input)
  
  updates
  |> list.filter(fn(a) { !page_order_follows_rules(a, before_rules, set.new()) }) 
  |> list.map(visit_unordered_pages(_, before_rules, after_rules))
  |> list.map(build_list_from_tree)
  |> list.try_map(get_middle_element)
  |> result.map(fn(a) { a |> int.sum |> int.to_string })
  |> result.unwrap("Could not find the middle element")
}
