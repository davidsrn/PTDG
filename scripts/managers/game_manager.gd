extends Node

## GameManager Singleton
## Manages game state, currency, waves, and overall game flow

# Signals for UI and other systems to listen to
signal credits_changed(new_amount: int)
signal processor_cores_changed(new_amount: int)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemy_reached_end()
signal game_over()
signal victory()

# Currency
var credits: int = 650:  # Starting credits (enough for a few towers)
	set(value):
		credits = max(0, value)
		credits_changed.emit(credits)

var processor_cores: int = 0:
	set(value):
		processor_cores = max(0, value)
		processor_cores_changed.emit(processor_cores)

# Game State
var current_wave: int = 0
var enemies_remaining: int = 0
var enemies_spawned: int = 0
var player_health: int = 100
var is_wave_active: bool = false

# Wave Configuration
var wave_configs: Array[Dictionary] = []

# Enemy Path (to be set by level)
var enemy_path: Path2D = null

# References
var active_enemies: Array[Node] = []
var placed_towers: Array[Node] = []


func _ready() -> void:
	print("GameManager initialized")
	_setup_default_waves()


## Initialize default wave configurations
func _setup_default_waves() -> void:
	wave_configs = [
		# Wave 1: 10 basic Glitches
		{"enemies": [{"type": "Glitch", "count": 10, "interval": 1.0}]},
		# Wave 2: 15 Glitches
		{"enemies": [{"type": "Glitch", "count": 15, "interval": 0.8}]},
		# Wave 3: 20 Glitches, 5 Bytes
		{"enemies": [
			{"type": "Glitch", "count": 20, "interval": 0.7},
			{"type": "Byte", "count": 5, "interval": 0.5}
		]},
		# Wave 4: 10 Clusters
		{"enemies": [{"type": "Cluster", "count": 10, "interval": 1.5}]},
		# Wave 5: Mixed with armored
		{"enemies": [
			{"type": "Glitch", "count": 15, "interval": 0.6},
			{"type": "ArmoredUnit", "count": 5, "interval": 1.0}
		]},
		# Wave 6: Stealth introduction
		{"enemies": [
			{"type": "Glitch", "count": 20, "interval": 0.5},
			{"type": "StealthUnit", "count": 8, "interval": 0.8}
		]},
		# Wave 7-9: Increasing difficulty
		{"enemies": [
			{"type": "Cluster", "count": 15, "interval": 1.2},
			{"type": "ArmoredUnit", "count": 10, "interval": 0.9}
		]},
		{"enemies": [
			{"type": "Glitch", "count": 30, "interval": 0.4},
			{"type": "StealthUnit", "count": 15, "interval": 0.6},
			{"type": "Cluster", "count": 10, "interval": 1.0}
		]},
		{"enemies": [
			{"type": "Cluster", "count": 20, "interval": 0.8},
			{"type": "ArmoredUnit", "count": 15, "interval": 0.7}
		]},
		# Wave 10: Boss wave
		{"enemies": [
			{"type": "OverlordConstruct", "count": 1, "interval": 5.0},
			{"type": "Cluster", "count": 10, "interval": 1.0}
		]}
	]


## Start the next wave
func start_wave() -> void:
	if is_wave_active:
		print("Wave already in progress!")
		return

	if current_wave >= wave_configs.size():
		print("All waves completed - Victory!")
		victory.emit()
		return

	is_wave_active = true
	current_wave += 1
	wave_started.emit(current_wave)
	print("Starting wave ", current_wave)

	# Spawn enemies according to wave config
	await _spawn_wave_enemies()


## Spawn enemies for the current wave
func _spawn_wave_enemies() -> void:
	var wave_config = wave_configs[current_wave - 1]

	for enemy_group in wave_config["enemies"]:
		for i in enemy_group["count"]:
			_spawn_enemy(enemy_group["type"])
			enemies_spawned += 1
			enemies_remaining += 1
			await get_tree().create_timer(enemy_group["interval"]).timeout


## Spawn a single enemy
func _spawn_enemy(enemy_type: String) -> void:
	# This will be implemented once enemy scenes are created
	# For now, just a placeholder
	print("Spawning enemy: ", enemy_type)
	# TODO: Load and instance enemy scene
	# var enemy = enemy_scene.instantiate()
	# enemy.initialize(enemy_path)
	# add_child(enemy)
	# active_enemies.append(enemy)


## Called when an enemy is destroyed
func enemy_destroyed(enemy: Node, credits_earned: int) -> void:
	enemies_remaining -= 1
	credits += credits_earned

	if active_enemies.has(enemy):
		active_enemies.erase(enemy)

	# Check if wave is complete
	if enemies_remaining <= 0 and is_wave_active:
		_complete_wave()


## Called when an enemy reaches the end of the path
func enemy_reached_end(enemy: Node) -> void:
	player_health -= 1
	enemies_remaining -= 1
	enemy_reached_end.emit()

	if active_enemies.has(enemy):
		active_enemies.erase(enemy)

	# Check for game over
	if player_health <= 0:
		_game_over()

	# Check if wave is complete
	if enemies_remaining <= 0 and is_wave_active:
		_complete_wave()


## Complete the current wave
func _complete_wave() -> void:
	is_wave_active = false
	enemies_spawned = 0
	wave_completed.emit(current_wave)
	print("Wave ", current_wave, " completed!")

	# Award processor cores for completing wave
	var cores_earned = current_wave  # 1 core per wave level
	processor_cores += cores_earned
	print("Earned ", cores_earned, " Processor Cores!")


## Game over handler
func _game_over() -> void:
	print("Game Over!")
	game_over.emit()
	# TODO: Show game over screen


## Register a placed tower
func register_tower(tower: Node) -> void:
	placed_towers.append(tower)


## Unregister a tower (if selling is implemented)
func unregister_tower(tower: Node) -> void:
	if placed_towers.has(tower):
		placed_towers.erase(tower)


## Check if player can afford a purchase
func can_afford(cost: int) -> bool:
	return credits >= cost


## Spend credits
func spend_credits(amount: int) -> bool:
	if can_afford(amount):
		credits -= amount
		return true
	return false


## Reset game state
func reset_game() -> void:
	credits = 650
	processor_cores = 0
	current_wave = 0
	enemies_remaining = 0
	enemies_spawned = 0
	player_health = 100
	is_wave_active = false

	# Clear active enemies and towers
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()

	for tower in placed_towers:
		if is_instance_valid(tower):
			tower.queue_free()
	placed_towers.clear()
