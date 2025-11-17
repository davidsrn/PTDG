extends Node
class_name UpgradeLogic

## UpgradeLogic Manager
## Handles upgrade validation, cost calculation, and path locking logic

## Calculate upgrade cost using exponential curve
## Formula: base_cost * (multiplier ^ (tier - 1))
static func calculate_upgrade_cost(base_cost: int, tier: int, multiplier: float = 2.5) -> int:
	if tier < 1:
		return 0
	return int(base_cost * pow(multiplier, tier - 1))


## Validate if an upgrade can be purchased
## Returns true if upgrade is valid, false otherwise
static func validate_upgrade(
	path: String,
	tier: int,
	current_tier_a: int,
	current_tier_b: int
) -> bool:
	# Validate path
	if path != "A" and path != "B":
		push_error("Invalid upgrade path: " + path)
		return false

	# Validate tier range
	if tier < 1 or tier > 4:
		push_error("Invalid tier: " + str(tier))
		return false

	# Get current tier for selected path
	var current_tier = current_tier_a if path == "A" else current_tier_b

	# Must upgrade sequentially (no skipping tiers)
	if tier != current_tier + 1:
		push_error("Cannot skip tiers. Current: " + str(current_tier) + ", Requested: " + str(tier))
		return false

	# Tiers 1-2: Always available if sequential
	if tier <= 2:
		return true

	# Tiers 3-4: Check path locking
	if path == "A":
		# Cannot upgrade Path A tier 3+ if Path B is already at tier 3+
		if current_tier_b >= 3:
			push_error("Path B is tier 3+, cannot upgrade Path A beyond tier 2")
			return false
	else:  # Path B
		# Cannot upgrade Path B tier 3+ if Path A is already at tier 3+
		if current_tier_a >= 3:
			push_error("Path A is tier 3+, cannot upgrade Path B beyond tier 2")
			return false

	return true


## Get the opposite path from the given path
static func get_opposite_path(path: String) -> String:
	if path == "A":
		return "B"
	elif path == "B":
		return "A"
	else:
		return ""


## Check if a path is locked due to opposite path being tier 3+
static func is_path_locked(
	path: String,
	current_tier_a: int,
	current_tier_b: int,
	requested_tier: int
) -> bool:
	if requested_tier < 3:
		return false  # Tiers 1-2 never locked

	if path == "A":
		return current_tier_b >= 3
	elif path == "B":
		return current_tier_a >= 3
	else:
		return true  # Invalid path is considered locked


## Get maximum available tier for a path
static func get_max_available_tier(
	path: String,
	current_tier_a: int,
	current_tier_b: int
) -> int:
	if path != "A" and path != "B":
		return 0

	var current_tier = current_tier_a if path == "A" else current_tier_b
	var opposite_tier = current_tier_b if path == "A" else current_tier_a

	# If already at tier 4, no more upgrades
	if current_tier >= 4:
		return 4

	# If opposite path is tier 3+, this path is locked at tier 2
	if opposite_tier >= 3:
		return 2

	# Otherwise, can go up to tier 4
	return 4


## Create a default upgrade path array
## Returns an array of 4 upgrade dictionaries with default values
static func create_default_upgrade_path(base_name: String, base_cost: int) -> Array[Dictionary]:
	var path: Array[Dictionary] = []

	for i in range(1, 5):
		var upgrade = {
			"tier": i,
			"name": base_name + " Tier " + str(i),
			"cost": calculate_upgrade_cost(base_cost, i),
			"description": "Upgrade tier " + str(i)
		}
		path.append(upgrade)

	return path


## Get upgrade info as formatted string
static func get_upgrade_info(upgrade_data: Dictionary) -> String:
	var info = ""
	info += "Name: " + upgrade_data.get("name", "Unknown") + "\n"
	info += "Cost: " + str(upgrade_data.get("cost", 0)) + " Credits\n"
	info += "Description: " + upgrade_data.get("description", "No description")
	return info


## Calculate total spent on upgrades
static func calculate_total_spent(
	upgrade_path_a: Array[Dictionary],
	upgrade_path_b: Array[Dictionary],
	current_tier_a: int,
	current_tier_b: int
) -> int:
	var total = 0

	# Sum Path A upgrades
	for i in range(current_tier_a):
		if i < upgrade_path_a.size():
			total += upgrade_path_a[i].get("cost", 0)

	# Sum Path B upgrades
	for i in range(current_tier_b):
		if i < upgrade_path_b.size():
			total += upgrade_path_b[i].get("cost", 0)

	return total


## Get sell value for a tower (typically 70% of total cost)
static func calculate_sell_value(total_cost: int, sell_percentage: float = 0.7) -> int:
	return int(total_cost * sell_percentage)


## Create upgrade data for a specific upgrade
static func create_upgrade_data(
	tier: int,
	name: String,
	cost: int,
	description: String,
	effects: Dictionary = {}
) -> Dictionary:
	return {
		"tier": tier,
		"name": name,
		"cost": cost,
		"description": description,
		"effects": effects
	}
