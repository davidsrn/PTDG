# Technical Specifications

## Godot Configuration

### Project Settings
```
Display Window:
  - Size: Viewport Width = 960, Viewport Height = 540
  - Stretch Mode: viewport
  - Stretch Aspect: keep
  - Pixel Snap: ON (2D)
```

### Rendering Settings
```
Textures:
  - Filter: Nearest (for pixel-perfect rendering)
  - Default Texture Filter: Nearest
```

---

## Core Classes Architecture

### 1. GameManager (Singleton/Autoload)
**Responsibilities:**
- Game state management (wave progression, win/loss conditions)
- Currency tracking (Credits, Processor Cores)
- Wave spawning
- UI coordination

**Key Properties:**
- `credits: int`
- `processor_cores: int`
- `current_wave: int`
- `enemies_remaining: int`
- `player_health: int`

### 2. Glitcher (Enemy Base Class)
**Extends:** CharacterBody2D or Area2D

**Core Properties:**
- `layers: int` - Number of health layers
- `speed: float` - Movement speed
- `credits_per_layer: int` - Credits awarded when layer is popped
- `is_armored: bool` - Immune to basic projectiles
- `is_stealthed: bool` - Requires detection to target
- `child_glitcher: PackedScene` - Next layer/child enemy spawned

**Core Methods:**
- `take_damage(amount: int, damage_type: String)`
- `pop_layer()` - Remove one layer and spawn child
- `move_along_path(delta: float)`

### 3. Defender (Tower Base Class)
**Extends:** Node2D

**Core Properties:**
- `base_cost: int` - Initial purchase cost
- `range: float` - Attack range in pixels
- `attack_speed: float` - Attacks per second
- `damage: int` - Base damage amount
- `damage_type: String` - "projectile", "energy", "splash", etc.
- `can_detect_stealth: bool` - Can target stealthed enemies
- `upgrade_path_a: Array[UpgradeData]`
- `upgrade_path_b: Array[UpgradeData]`
- `current_tier_a: int`
- `current_tier_b: int`

**Core Methods:**
- `find_target() -> Glitcher`
- `attack(target: Glitcher)`
- `upgrade(path: String, tier: int) -> bool`
- `can_upgrade(path: String, tier: int) -> bool`

### 4. UpgradeLogic (Resource/Manager)
**Responsibilities:**
- Validate upgrade purchases
- Calculate upgrade costs (exponential curve)
- Handle path locking (Tier 3+ restrictions)

**Cost Formula:**
```gdscript
func calculate_upgrade_cost(base_cost: int, tier: int) -> int:
    return int(base_cost * pow(2.5, tier - 1))
```

**Locking Logic:**
- Tiers 1-2: Both paths available
- Tier 3+: Purchasing on Path A locks Path B tier 3+, and vice versa

---

## Shader Implementation

### 1. Neon Glow Shader (neon_glow.gdshader)
**Type:** CanvasItem Shader
**Purpose:** Create glowing neon effect for towers, UI elements, lights

**Key Parameters:**
- `glow_color: vec3` - RGB color of the glow
- `glow_intensity: float` - Strength of glow
- `pulse_speed: float` - Animation speed

### 2. Rain Shader (rain.gdshader)
**Type:** CanvasItem Shader
**Purpose:** Animated rain particles

**Key Parameters:**
- `rain_density: float` - Number of rain streaks
- `rain_speed: float` - Fall speed
- `rain_angle: float` - Direction of rain

### 3. Wet Surface Shader (wet_surface.gdshader)
**Type:** CanvasItem Shader
**Purpose:** Reflective puddles and wet ground

**Key Parameters:**
- `reflection_strength: float`
- `distortion_amount: float`

---

## Enemy Type Specifications

### Glitch (Base Enemy)
- Layers: 1
- Speed: 100 px/s
- Credits: 1
- Child: Byte

### Byte (Small Fast Enemy)
- Layers: 1
- Speed: 150 px/s
- Credits: 1
- Child: None

### Cluster (Large Enemy)
- Layers: 3
- Speed: 60 px/s
- Credits: 3
- Child: 3× Glitch

### Armored Unit
- Layers: 2
- Speed: 80 px/s
- Credits: 2
- Property: `is_armored = true`

### Stealth Unit
- Layers: 1
- Speed: 120 px/s
- Credits: 2
- Property: `is_stealthed = true`

### Overlord Construct (Boss)
- Layers: 10
- Speed: 30 px/s
- Credits: 100
- Child: 5× Cluster

---

## Tower Type Specifications

### 1. Pulse Cannon (Projectile Tower)
- Base Cost: 200 Credits
- Range: 160px (5 tiles)
- Damage: 1
- Attack Speed: 1.0/s
- Damage Type: "projectile"

**Path A - Rapid Fire:**
- T1: +0.5 attack speed (300 Credits)
- T2: +0.5 attack speed (750 Credits)
- T3: +1.0 attack speed, +1 damage (1800 Credits)
- T4: Triple shot (4500 Credits)

**Path B - Armor Piercing:**
- T1: +1 damage (300 Credits)
- T2: +1 damage (750 Credits)
- T3: Can damage armored (1800 Credits)
- T4: +3 damage, explosive rounds (4500 Credits)

### 2. EMP Blaster (Splash Tower)
- Base Cost: 400 Credits
- Range: 128px (4 tiles)
- Damage: 1
- Splash Radius: 64px
- Attack Speed: 0.5/s
- Damage Type: "energy"

### 3. Scanner Array (Detection/Debuff Tower)
- Base Cost: 300 Credits
- Range: 192px (6 tiles)
- Provides detection for stealthed enemies
- Can slow enemies

### 4. Data Farm (Economic Tower)
- Base Cost: 500 Credits
- No attack capability
- Generates Credits passively per round
