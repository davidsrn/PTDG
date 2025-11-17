# Getting Started with Cyber-Defense Development

## First Time Setup

### 1. Install Godot Engine

Download Godot 4.3 or later from [godotengine.org](https://godotengine.org/)

- **Standard Version** is sufficient for 2D development
- **Mono/.NET Version** is NOT required (we use GDScript)

### 2. Open the Project

1. Launch Godot
2. Click "Import"
3. Navigate to the project folder
4. Select `project.godot`
5. Click "Import & Edit"

### 3. Familiarize Yourself with the Structure

Key files to understand:

- `scenes/levels/main_level.tscn` - Main game scene, start here
- `scripts/managers/game_manager.gd` - Game state singleton
- `scripts/enemies/glitcher.gd` - Enemy base class
- `scripts/towers/defender.gd` - Tower base class

## Running the Game

1. Open `main_level.tscn`
2. Press F5 or click the Play button
3. You should see:
   - Cyberpunk-themed background
   - Animated rain effect
   - UI showing Credits, Wave, Health, Processor Cores
   - "Start Wave" button

**Note**: The game is currently in foundation state. Enemies won't spawn yet because the path system needs to be completed.

## Current Limitations

The following systems are **implemented but need additional work**:

### ✅ Implemented
- Core class architecture
- GameManager singleton
- Enemy movement and layering logic
- Tower targeting and upgrade system
- Cyberpunk shaders (neon glow, rain, wet surfaces)
- UI framework

### ⚠️ Partially Implemented
- Enemy spawning (logic exists, needs path integration)
- Tower placement (needs grid system and UI)
- Wave progression (GameManager ready, needs connection)

### ❌ Not Yet Implemented
- Enemy path (Path2D curve needs to be drawn)
- Tower placement grid
- Projectile visuals
- Additional enemy types (only Glitch and Byte exist)
- Additional tower types (only Pulse Cannon exists)
- Sound effects
- Meta-progression system
- Level progression
- Win/Loss screens

## Immediate Next Steps for Development

### Priority 1: Complete the Path System

**File to edit**: `scenes/levels/main_level.tscn`

1. Select the `EnemyPath` node (Path2D)
2. Use the Path2D editing tools to draw a curved path
3. The path should:
   - Start off-screen left (e.g., x:-50)
   - Wind through the playable area
   - End off-screen right (e.g., x:1010)
   - Have smooth curves using Bezier handles

**Example path structure**:
```
Start (-50, 270)
→ Curve to (200, 200)
→ Curve to (300, 350)
→ Curve to (500, 250)
→ Curve to (700, 350)
→ End (1010, 270)
```

4. Update `PathLine` to visualize the path:
   - Set `points` to match your curve
   - Adjust `width` for visual clarity

### Priority 2: Connect Enemy Spawning

**File to edit**: `scripts/managers/game_manager.gd`

Find the `_spawn_enemy()` function and implement:

```gdscript
func _spawn_enemy(enemy_type: String) -> void:
	var enemy_scene: PackedScene = null

	match enemy_type:
		"Glitch":
			enemy_scene = load("res://scenes/enemies/glitch_basic.tscn")
		"Byte":
			enemy_scene = load("res://scenes/enemies/byte_small.tscn")
		# Add more types as you create them

	if enemy_scene and enemy_path:
		var enemy = enemy_scene.instantiate()
		enemy_path.add_child(enemy)
		enemy.initialize(enemy_path)
		enemy.path_parent = enemy_path
		active_enemies.append(enemy)

		# Connect signals
		enemy.destroyed.connect(
			func(credits): enemy_destroyed(enemy, credits)
		)
		enemy.reached_end.connect(
			func(): enemy_reached_end(enemy)
		)
```

### Priority 3: Create Tower Placement System

**New file to create**: `scripts/ui/tower_placement.gd`

This script should:
1. Show a grid overlay when placing towers
2. Highlight valid placement locations
3. Show tower range preview
4. Handle click-to-place mechanics

**Attach to**: A new Node2D in `main_level.tscn`

### Priority 4: Test the Core Loop

Once steps 1-3 are complete, you should be able to:

1. Click "Start Wave"
2. Watch enemies spawn and move along the path
3. Place towers (when placement system is added)
4. Watch towers attack enemies
5. See enemies pop layers and spawn children
6. Earn credits and processor cores

## Understanding the Upgrade System

The upgrade system is a key mechanic inspired by BTD:

### Branching Paths
Each tower has **Path A** and **Path B**

- Tiers 1-2: Can buy from both paths
- Tier 3+: Buying from one path **locks** the other

### Cost Scaling
Upgrades use exponential cost:
```
Cost = base_cost × (2.5 ^ (tier - 1))
```

Example for 300 base cost:
- Tier 1: 300
- Tier 2: 750
- Tier 3: 1,875
- Tier 4: 4,687

### Implementation Example

To create a custom tower:

1. **Create a new script** extending `Defender`:

```gdscript
extends Defender
class_name EMPBlaster

func _ready():
	super._ready()
	tower_name = "EMP Blaster"
	base_cost = 400
	attack_range = 128.0
	damage_type = "energy"
	splash_radius = 64.0

func _setup_upgrades():
	upgrade_path_a = [
		{"name": "Wider Blast", "cost": 400, "description": "+32px splash radius"},
		{"name": "Even Wider", "cost": 1000, "description": "+32px splash radius"},
		{"name": "EMP Storm", "cost": 2500, "description": "+64px splash, stuns"},
		{"name": "Blackout", "cost": 6250, "description": "Huge radius, disables"}
	]
	# ... define path_b
```

## Working with Shaders

### Applying Neon Glow to a Sprite

1. Select your Sprite2D node
2. In Inspector, expand "Material"
3. Create New ShaderMaterial
4. Set Shader to `res://shaders/neon_glow.gdshader`
5. Adjust parameters:
   - `glow_color`: RGB color (cyan = 0,1,1)
   - `glow_intensity`: 1.5 - 3.0 for strong glow
   - `pulse_speed`: 2.0 - 4.0 for animation

### Adding Rain to a Scene

Rain is already applied in `main_level.tscn` via the `RainOverlay` ColorRect. To adjust:

1. Select `UI/RainOverlay`
2. Expand Material → Shader Parameters
3. Adjust:
   - `rain_density`: Higher = more rain
   - `rain_speed`: How fast it falls
   - `rain_angle`: Diagonal direction

## Debugging Tips

### Enemies Not Spawning?
- Check that `enemy_path` is set in GameManager
- Verify Path2D has a valid curve
- Look for errors in the Output panel

### Towers Not Attacking?
- Ensure enemies are in `enemies_in_range` array
- Check that enemy is not stealthed (or tower has detection)
- Verify attack_timer is incrementing

### UI Not Updating?
- Check that GameManager signals are connected
- Verify `level_ui.gd` is attached to the CanvasLayer
- Look for null references in labels

### Shader Not Showing?
- Ensure texture filter is set to "Nearest" in Project Settings
- Check that shader parameters are visible in Inspector
- Verify shader file has no syntax errors

## Useful Godot Shortcuts

- `F5`: Run project
- `F6`: Run current scene
- `F7`: Stop running project
- `Ctrl+D`: Duplicate node
- `Ctrl+Shift+D`: Duplicate node with children
- `Ctrl+A`: Add new node

## Resources

- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [Godot Shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/)

## Getting Help

If you get stuck:

1. Check the Output panel in Godot for error messages
2. Review the knowledge base docs in `docs/knowledge_base/`
3. Read the inline code comments in the scripts
4. Consult Godot's documentation for node types and methods

---

Happy coding! Build something awesome! 🎮✨
