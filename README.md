# Cyber-Defense

A challenging Tower Defense game with a **Cyberpunk 8-bit theme**, inspired by Bloons Tower Defense (BTD) mechanics.

## Project Status

Initial foundation setup completed! The project now includes:

- ✅ Godot 4.x project structure
- ✅ Core game systems (GameManager, Enemies, Towers, Upgrades)
- ✅ Cyberpunk aesthetic shaders (Neon Glow, Rain, Wet Surface)
- ✅ Basic UI and game scene
- ✅ Placeholder assets for testing

## Getting Started

### Prerequisites

- Godot Engine 4.3 or later
- Basic understanding of GDScript and Godot's node system

### Opening the Project

1. Clone this repository
2. Open Godot Engine
3. Click "Import" and navigate to the project folder
4. Select `project.godot` and click "Import & Edit"

## Project Structure

```
PTDG/
├── docs/
│   ├── knowledge_base/     # Project documentation
│   │   ├── PROJECT_OVERVIEW.md
│   │   └── TECHNICAL_SPECS.md
│   └── design/             # Design documents
├── scripts/
│   ├── enemies/            # Enemy (Glitcher) scripts
│   │   └── glitcher.gd
│   ├── towers/             # Tower (Defender) scripts
│   │   └── defender.gd
│   ├── managers/           # Game management scripts
│   │   ├── game_manager.gd
│   │   └── upgrade_logic.gd
│   └── ui/                 # UI scripts
│       └── level_ui.gd
├── scenes/
│   ├── enemies/            # Enemy scenes
│   │   ├── glitch_basic.tscn
│   │   └── byte_small.tscn
│   ├── towers/             # Tower scenes
│   │   └── pulse_cannon.tscn
│   ├── levels/             # Level/map scenes
│   │   └── main_level.tscn
│   └── ui/                 # UI scenes
├── assets/
│   ├── sprites/            # Image assets (SVG placeholders)
│   │   ├── glitch_basic.svg
│   │   ├── byte_small.svg
│   │   ├── cluster_large.svg
│   │   └── tower_pulse.svg
│   ├── audio/              # Sound effects and music
│   └── fonts/              # Fonts for UI
└── shaders/                # Shader files
    ├── neon_glow.gdshader
    ├── neon_outline.gdshader
    ├── rain.gdshader
    └── wet_surface.gdshader
```

## Core Features

### Game Mechanics (BTD-Inspired)

- **Layered Enemy Health**: Enemies have multiple layers that reveal weaker units when destroyed
- **Branching Tower Upgrades**: Two upgrade paths with 4 tiers each, tier 3+ locks the opposite path
- **Dual Currency System**:
  - `Credits`: Earned by defeating enemies, used for towers and upgrades
  - `Processor Cores`: Earned on level completion, used for permanent bonuses
- **Enemy Properties**:
  - Armored: Immune to basic projectiles
  - Stealthed: Requires detection to target

### Technical Features

- **32×32 Pixel Tile Grid**: All assets aligned to grid
- **Low Resolution**: 960×540 base with viewport scaling for crisp pixels
- **Advanced Shaders**:
  - Neon glow effects for cyberpunk aesthetic
  - Animated rain with wind simulation
  - Wet surface reflections
  - Neon outline shader for highlights

## Core Systems

### GameManager (Singleton/Autoload)

Manages game state, currency, waves, and overall flow.

**Key Properties:**
- `credits: int` - Player's money for towers/upgrades
- `processor_cores: int` - Meta-currency for permanent upgrades
- `current_wave: int` - Current wave number
- `player_health: int` - Lives remaining

**Key Methods:**
- `start_wave()` - Begin next wave
- `enemy_destroyed()` - Handle enemy defeat
- `spend_credits()` - Purchase validation

### Glitcher (Enemy Base Class)

Extends `PathFollow2D` for enemies that move along paths.

**Key Properties:**
- `layers: int` - Health layers
- `speed: float` - Movement speed
- `is_armored: bool` - Immune to projectiles
- `is_stealthed: bool` - Requires detection
- `child_glitcher: PackedScene` - Spawned on layer pop

**Key Methods:**
- `take_damage()` - Apply damage with type checking
- `pop_layer()` - Remove one layer
- `can_be_detected_by()` - Check tower detection

### Defender (Tower Base Class)

Extends `Node2D` for placeable towers.

**Key Properties:**
- `attack_range: float` - Range in pixels
- `attack_speed: float` - Attacks per second
- `damage: int` - Base damage
- `damage_type: String` - "projectile", "energy", "splash"
- `can_detect_stealth: bool` - Can target stealthed enemies
- `upgrade_path_a/b: Array[Dictionary]` - Upgrade definitions

**Key Methods:**
- `find_target()` - Get best enemy in range
- `attack()` - Execute attack
- `upgrade()` - Purchase upgrade
- `can_upgrade()` - Validate upgrade availability

### UpgradeLogic (Static Utility Class)

Handles upgrade validation and cost calculation.

**Key Methods:**
- `calculate_upgrade_cost()` - Exponential cost formula
- `validate_upgrade()` - Check path locking rules
- `is_path_locked()` - Check if tier 3+ is blocked
- `calculate_sell_value()` - Get refund amount

## Enemy Types

### Glitch (Base Enemy)
- Layers: 1
- Speed: 100 px/s
- Spawns: 1× Byte

### Byte (Fast Enemy)
- Layers: 1
- Speed: 150 px/s
- Spawns: None

### Cluster (Large Enemy)
- Layers: 3
- Speed: 60 px/s
- Spawns: 3× Glitch

### Armored Unit
- Layers: 2
- Property: `is_armored = true`

### Stealth Unit
- Layers: 1
- Property: `is_stealthed = true`

### Overlord Construct (Boss)
- Layers: 10
- Speed: 30 px/s
- Spawns: 5× Cluster

## Tower Types

### Pulse Cannon (Projectile Tower)
- Cost: 200 Credits
- Range: 160px (5 tiles)
- Damage: 1
- Attack Speed: 1.0/s

**Path A - Rapid Fire:**
- T1-T2: +0.5 attack speed each
- T3: +1.0 attack speed, +1 damage
- T4: Triple shot

**Path B - Armor Piercing:**
- T1-T2: +1 damage each
- T3: Can damage armored
- T4: +3 damage, explosive rounds

## Shaders

### neon_glow.gdshader
Creates pulsing neon glow effect with customizable color, intensity, and pulse rate.

**Parameters:**
- `glow_color: Color` - RGB color of glow
- `glow_intensity: float` - Brightness
- `pulse_speed: float` - Animation speed

### rain.gdshader
Animated rain with multiple layers, wind simulation, and neon-tinted droplets.

**Parameters:**
- `rain_density: float` - Number of droplets
- `rain_speed: float` - Fall speed
- `rain_angle: float` - Diagonal direction
- `enable_wind: bool` - Dynamic wind effect

### wet_surface.gdshader
Creates reflective puddles with ripple distortion and animated patterns.

**Parameters:**
- `reflection_strength: float` - Mirror intensity
- `distortion_amount: float` - Ripple strength
- `puddle_scale: float` - Pattern size

## Next Steps

### Immediate Development Tasks

1. **Enemy Path System**
   - Create Path2D with proper curve in main_level.tscn
   - Add visual path indicators
   - Implement waypoint system

2. **Tower Placement System**
   - Create placement grid visualization
   - Add click-to-place mechanic
   - Implement placement validation

3. **Additional Enemy Types**
   - Create cluster_large.tscn scene
   - Create armored_unit.tscn scene
   - Create stealth_unit.tscn scene
   - Create overlord_construct.tscn (boss)

4. **Additional Tower Types**
   - EMP Blaster (Splash Tower)
   - Scanner Array (Detection/Debuff)
   - Data Farm (Economic Tower)

5. **Combat System**
   - Implement projectile spawning
   - Add visual attack effects
   - Create damage numbers popup

6. **Meta-Progression**
   - Processor Cores shop UI
   - Permanent upgrade system
   - Player progression save/load

7. **Polish & Effects**
   - Attack animations
   - Death animations
   - Screen shake on damage
   - Sound effects integration

### Export Targets

- **Web (WebGL)**: HTML5 export for browser play
- **Android**: APK build with touch controls
- **iOS**: IPA build (requires Mac for signing)

## Development Notes

- All coordinates use 32×32 pixel grid alignment
- Use `@export` for inspector-visible properties
- All visual effects should use provided shaders
- Follow BTD-style progression curves for difficulty
- Maintain cyberpunk aesthetic in all new assets

## Contributing

This is a learning/portfolio project. Feel free to fork and experiment!

## License

[Add your preferred license here]

---

**Built with Godot 4.x | GDScript**
