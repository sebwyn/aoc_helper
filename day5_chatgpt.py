def parse_input(input_data):
    # Split input data into rules and updates
    rules = []
    updates = []
    section = 0  # 0 for rules, 1 for updates
    
    for line in input_data:
        line = line.strip()
        if not line:
            section += 1
            continue
        if section == 0:
            rules.append(line)
        else:
            updates.append(list(map(int, line.split(','))))
    
    return rules, updates

def build_graph(rules):
    # Build the dependency graph from the rules
    from collections import defaultdict
    
    graph = defaultdict(list)
    in_degree = defaultdict(int)
    
    for rule in rules:
        before, after = map(int, rule.split('|'))
        graph[before].append(after)
        in_degree[after] += 1
        if before not in in_degree:
            in_degree[before] = 0
    
    return graph, in_degree

def is_valid_order(update, graph, in_degree):
    # Check if a given update is in valid order according to the rules
    position = {page: idx for idx, page in enumerate(update)}
    
    for page in update:
        for neighbor in graph[page]:
            if position[page] > position[neighbor]:
                return False
    return True

def find_middle_page(update):
    # Find the middle page of an update
    sorted_pages = sorted(update)
    middle_index = len(sorted_pages) // 2
    return sorted_pages[middle_index]

def main(input_data):
    rules, updates = parse_input(input_data)
    graph, in_degree = build_graph(rules)
    
    total_middle_page_sum = 0
    
    for update in updates:
        if is_valid_order(update, graph, in_degree):
            middle_page = find_middle_page(update)
            total_middle_page_sum += middle_page
    
    return total_middle_page_sum

# Example usage:
input_data = [
    "47|53",
    "97|13",
    "97|61",
    "97|47",
    "75|29",
    "61|13",
    "75|53",
    "29|13",
    "97|29",
    "53|29",
    "61|53",
    "97|53",
    "61|29",
    "47|13",
    "75|47",
    "97|75",
    "47|61",
    "75|61",
    "47|29",
    "75|13",
    "53|13",
    "",
    "75,47,61,53,29",
    "97,61,53,29,13",
    "75,29,13",
    "75,97,47,61,53",
    "61,13,29",
    "97,13,75,29,47"
]

result = main(input_data)
print(result)  # Expected output: 143
