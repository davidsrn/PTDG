extends Node2D
class_name Defender

## Base class for all towers (Defenders)
## Handles targeting, attacking, and upgrade management

# Signals
signal target_found(target: Glitcher)
signal attack_fired(target: Glitcher)
signal upgraded(path: String, tier: int)

# Core Properties
@export var tower_name: String = "Basic Defender"
@export var base_cost: int = 200
@export var attack_range: float = 160.0  # In pixels (5 tiles * 32px)
@export var attack_speed: float = 1.0  # Attacks per second
@export var damage: int = 1
@export var damage_type: String = "projectile"  # "projectile", "energy", "splash"
@export var can_detect_stealth: bool = false
@export var is_economic: bool = false  # True for Data Farm type towers

# Splash damage (if applicable)
@export var splash_radius: float = 0.0

# Upgrade Paths
var upgrade_path_a: Array[Dictionary] = []
var upgrade_path_b: Array[Dictionary] = []
var current_tier_a: int = 0
var current_tier_b: int = 0

# Internal State
var current_target: Glitcher = null
var attack_timer: float = 0.0
var enemies_in_range: Array[Glitcher] = []

# Node References
@onready var range_area: Area2D = $RangeArea
@onready var range_collision: CollisionShape2D = $RangeArea/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_point: Marker2D = $AttackPoint


func _ready() -> void:
	_setup_range()
	_setup_upgrades()
	_connect_signals()


func _process(delta: float) -> void:
	if is_economic:
		return  # Economic towers don't attack

	# Update attack timer
	attack_timer += delta

	# Find and attack target
	if attack_timer >= 1.0 / attack_speed:
		_find_and_attack_target()
		attack_timer = 0.0


## Setup the range detection area
func _setup_range() -> void:
	if range_collision and range_collision.shape is CircleShape2D:
		range_collision.shape.radius = attack_range


## Connect area signals
func _connect_signals() -> void:
	if range_area:
		range_area.body_entered.connect(_on_enemy_entered_range)
		range_area.body_exited.connect(_on_enemy_exited_range)
		range_area.area_entered.connect(_on_enemy_area_entered)
		range_area.area_exited.connect(_on_enemy_area_exited)


## Define upgrade paths (to be overridden by specific tower types)
func _setup_upgrades() -> void:
	# Default paths - override in specific tower scripts
	upgrade_path_a = [
		{"name": "Faster Shooting I", "cost": 300, "description": "+0.5 attack speed"},
		{"name": "Faster Shooting II", "cost": 750, "description": "+0.5 attack speed"},
		{"name": "Rapid Fire", "cost": 1800, "description": "+1.0 attack speed"},
		{"name": "Maximum Overdrive", "cost": 4500, "description": "+2.0 attack speed"}
	]

	upgrade_path_b = [
		{"name": "Sharper Bits I", "cost": 300, "description": "+1 damage"},
		{"name": "Sharper Bits II", "cost": 750, "description": "+1 damage"},
		{"name": "Piercing Rounds", "cost": 1800, "description": "+2 damage, pierce armor"},
		{"name": "Devastation", "cost": 4500, "description": "+5 damage, large pierce"}
	]


## Find the best target in range
func find_target() -> Glitcher:
	# Remove invalid enemies
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e) and e.is_alive)

	if enemies_in_range.is_empty():
		return null

	# Targeting priority: furthest along path (highest progress_ratio)
	var best_target: Glitcher = null
	var best_progress: float = -1.0

	for enemy in enemies_in_range:
		# Check if we can detect this enemy
		if enemy.is_stealthed and not can_detect_stealth:
			continue

		if enemy.progress_ratio > best_progress:
			best_progress = enemy.progress_ratio
			best_target = enemy

	return best_target


## Find target and execute attack
func _find_and_attack_target() -> void:
	current_target = find_target()

	if current_target:
		attack(current_target)


## Execute attack on target
func attack(target: Glitcher) -> void:
	if not target or not is_instance_valid(target) or not target.is_alive:
		return

	attack_fired.emit(target)

	# Visual: rotate towards target
	_rotate_to_target(target)

	# Spawn projectile or apply damage
	if damage_type == "splash":
		_splash_attack(target)
	else:
		_direct_attack(target)

	# Play attack animation
	_play_attack_animation()


## Direct damage attack
func _direct_attack(target: Glitcher) -> void:
	# TODO: Spawn projectile for visual effect
	# For now, apply damage directly
	target.take_damage(damage, damage_type)


## Splash damage attack
func _splash_attack(target: Glitcher) -> void:
	# Deal damage to target
	target.take_damage(damage, damage_type)

	# Deal damage to nearby enemies
	if splash_radius > 0:
		for enemy in enemies_in_range:
			if enemy == target or not is_instance_valid(enemy):
				continue

			var distance = global_position.distance_to(enemy.global_position)
			if distance <= splash_radius:
				enemy.take_damage(damage, damage_type)


## Rotate sprite to face target
func _rotate_to_target(target: Glitcher) -> void:
	if sprite and target:
		var direction = (target.global_position - global_position).normalized()
		sprite.rotation = direction.angle()


## Play attack animation
func _play_attack_animation() -> void:
	# Simple recoil animation
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.05)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)


## Attempt to purchase an upgrade
func upgrade(path: String, tier: int) -> bool:
	if not can_upgrade(path, tier):
		return false

	var upgrade_data: Dictionary
	var cost: int

	if path == "A":
		upgrade_data = upgrade_path_a[tier - 1]
		cost = upgrade_data["cost"]
	elif path == "B":
		upgrade_data = upgrade_path_b[tier - 1]
		cost = upgrade_data["cost"]
	else:
		return false

	# Check if player can afford
	if not GameManager.spend_credits(cost):
		print("Not enough credits for upgrade!")
		return false

	# Apply upgrade
	if path == "A":
		current_tier_a = tier
		_apply_upgrade_a(tier)
	else:
		current_tier_b = tier
		_apply_upgrade_b(tier)

	upgraded.emit(path, tier)
	print("Upgraded to ", path, " tier ", tier)
	return true


## Check if an upgrade is available
func can_upgrade(path: String, tier: int) -> bool:
	# Validate tier
	if tier < 1 or tier > 4:
		return false

	# Check current progress on this path
	var current_tier = current_tier_a if path == "A" else current_tier_b
	if tier != current_tier + 1:
		return false  # Must upgrade sequentially

	# Tier 1-2: Always available (if sequential)
	if tier <= 2:
		return true

	# Tier 3-4: Check locking rules
	if path == "A":
		# Cannot upgrade Path A tier 3+ if Path B is tier 3+
		if current_tier_b >= 3:
			return false
	else:  # Path B
		# Cannot upgrade Path B tier 3+ if Path A is tier 3+
		if current_tier_a >= 3:
			return false

	return true


## Apply Path A upgrade effects (override in specific towers)
func _apply_upgrade_a(tier: int) -> void:
	match tier:
		1:
			attack_speed += 0.5
		2:
			attack_speed += 0.5
		3:
			attack_speed += 1.0
		4:
			attack_speed += 2.0


## Apply Path B upgrade effects (override in specific towers)
func _apply_upgrade_b(tier: int) -> void:
	match tier:
		1:
			damage += 1
		2:
			damage += 1
		3:
			damage += 2
			damage_type = "energy"  # Can pierce armor
		4:
			damage += 5


## Get total cost of tower including upgrades
func get_total_cost() -> int:
	var total = base_cost

	for i in current_tier_a:
		total += upgrade_path_a[i]["cost"]

	for i in current_tier_b:
		total += upgrade_path_b[i]["cost"]

	return total


## Called when enemy enters range
func _on_enemy_entered_range(body: Node2D) -> void:
	if body is Glitcher:
		if not enemies_in_range.has(body):
			enemies_in_range.append(body)


## Called when enemy exits range
func _on_enemy_exited_range(body: Node2D) -> void:
	if body is Glitcher:
		enemies_in_range.erase(body)


## Called when enemy area enters range
func _on_enemy_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is Glitcher:
		if not enemies_in_range.has(enemy):
			enemies_in_range.append(enemy)


## Called when enemy area exits range
func _on_enemy_area_exited(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is Glitcher:
		enemies_in_range.erase(enemy)
