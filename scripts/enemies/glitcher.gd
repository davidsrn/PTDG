extends PathFollow2D
class_name Glitcher

## Base class for all enemies (Glitchers)
## Handles layered health, movement, and special properties

# Signals
signal layer_popped(credits_earned: int)
signal destroyed(credits_earned: int)
signal reached_end()

# Core Properties
@export var layers: int = 1  # Number of health layers
@export var speed: float = 100.0  # Movement speed in pixels/second
@export var credits_per_layer: int = 1  # Credits awarded per layer popped
@export var is_armored: bool = false  # Immune to basic projectiles
@export var is_stealthed: bool = false  # Requires detection to target
@export var child_glitcher: PackedScene = null  # Enemy spawned when layer is popped
@export var child_count: int = 1  # Number of children spawned

# Visual
@export var sprite_texture: Texture2D = null
@export var glow_color: Color = Color.CYAN

# Internal state
var current_layers: int = 0
var is_alive: bool = true
var path_parent: Path2D = null

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	current_layers = layers
	_setup_visuals()
	_update_health_bar()

	# Apply stealth visual if needed
	if is_stealthed:
		modulate.a = 0.5  # Semi-transparent


func _process(delta: float) -> void:
	if not is_alive:
		return

	# Move along the path
	progress += speed * delta

	# Check if reached end of path
	if progress_ratio >= 1.0:
		_reached_end()


## Setup visual components
func _setup_visuals() -> void:
	if sprite and sprite_texture:
		sprite.texture = sprite_texture

	# Apply glow shader material if available
	# TODO: Apply neon glow shader when created


## Take damage from a tower
func take_damage(amount: int, damage_type: String = "projectile") -> void:
	if not is_alive:
		return

	# Check armor immunity
	if is_armored and damage_type == "projectile":
		# Armored enemies are immune to basic projectiles
		_show_immune_indicator()
		return

	# Apply damage (each hit removes layers)
	for i in amount:
		if current_layers > 0:
			pop_layer()


## Pop one layer of the enemy
func pop_layer() -> void:
	if not is_alive:
		return

	current_layers -= 1
	_update_health_bar()

	# Emit signal for credits
	layer_popped.emit(credits_per_layer)

	# Award credits immediately
	if GameManager:
		GameManager.credits += credits_per_layer

	if current_layers <= 0:
		_destroy()
	else:
		# Visual feedback for layer pop
		_play_pop_animation()


## Destroy this enemy and spawn children
func _destroy() -> void:
	if not is_alive:
		return

	is_alive = false

	# Spawn child enemies if configured
	if child_glitcher and path_parent:
		for i in child_count:
			_spawn_child()

	# Notify GameManager
	destroyed.emit(credits_per_layer * layers)
	if GameManager:
		GameManager.enemy_destroyed(self, 0)  # Credits already awarded per layer

	# Play death animation and remove
	_play_death_animation()
	await get_tree().create_timer(0.2).timeout
	queue_free()


## Spawn a child enemy at current position
func _spawn_child() -> void:
	if not child_glitcher or not path_parent:
		return

	var child = child_glitcher.instantiate()
	child.path_parent = path_parent

	# Add to path
	path_parent.add_child(child)

	# Set child to current position
	if child is PathFollow2D:
		child.progress = progress


## Called when enemy reaches end of path
func _reached_end() -> void:
	if not is_alive:
		return

	is_alive = false
	reached_end.emit()

	# Notify GameManager
	if GameManager:
		GameManager.handle_enemy_reached_end(self)

	queue_free()


## Update health bar visual
func _update_health_bar() -> void:
	if health_bar:
		health_bar.max_value = layers
		health_bar.value = current_layers


## Show immune indicator effect
func _show_immune_indicator() -> void:
	# TODO: Add visual feedback for immunity
	# For now, just a flash effect
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.GRAY, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)


## Play layer pop animation
func _play_pop_animation() -> void:
	# Simple scale bounce effect
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)


## Play death animation
func _play_death_animation() -> void:
	# Fade out and shrink
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), 0.2)


## Initialize enemy with a path
func initialize(path: Path2D) -> void:
	path_parent = path


## Check if this enemy can be detected by a tower
func can_be_detected_by(tower) -> bool:
	if not is_stealthed:
		return true
	# Check if tower has detection capability
	if tower and "can_detect_stealth" in tower:
		return tower.can_detect_stealth
	return false
