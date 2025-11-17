# Cyber-Defense - Project Overview

## Project Goal
A challenging Tower Defense game with a **Cyberpunk 8-bit theme**, inspired by Bloons Tower Defense (BTD) mechanics.

## Platform Targets
- Web (WebGL)
- Android
- iOS

## Engine & Language
- **Godot Engine 4.x**
- **GDScript** for core logic

---

## Core Technical Specifications

### Aesthetic Requirements
- **Visual Style:** Dark, rainy, neon-lit cyberpunk atmosphere
- **Tile Size:** 32×32 pixel grid for all assets and level components
- **Base Resolution:** 960×540 (low-res for crisp pixel rendering)
- **Viewport Settings:** Viewport/Keep Aspect with integer scaling

### Shader Effects (CanvasItem Shaders)
1. **Neon Glow/Bloom** - For lights and tower components
2. **Dynamic 2D Lighting** - Shadows and highlights on environment
3. **Animated Rain** - Weather effects
4. **Wet Surface Reflections** - Environmental depth

---

## Core Mechanics

### Economy System
- **Primary Currency:** `Credits` (earned by destroying enemies, 1 per layer popped)
- **Secondary Currency:** `Processor Cores` (earned on level completion, used for permanent upgrades)
- **Economic Towers:** Data Farm type for passive Credit generation

### Enemy System ("Glitchers")
- **Layered Health:** Base unit `Glitch` → reveals `Byte` when destroyed
- **Larger Units:** `Cluster` releases multiple layered units
- **Special Properties:**
  - **Armored (Lead equivalent):** Immune to basic projectiles, requires energy/high-impact damage
  - **Stealthed (Camo equivalent):** Requires Detection Towers or special upgrades
- **Boss Enemy:** `Overlord Construct` (MOAB-class equivalent)

### Tower System ("Defenders")
- **Minimum 4 Core Types:** Projectile, Splash, Debuff, Anti-Armor
- **Branching Upgrade System:**
  - 2 paths per tower (Path A, Path B)
  - 4 tiers per path
  - Tiers 1-2: Can purchase from both paths
  - Tier 3+: Locks opposite path (forces specialization)
  - Exponential cost curve

### Game Structure
- **Path Type:** Static/Fixed pre-defined lane
- **Tower Placement:** Pre-designated 32×32 pixel nodes adjacent to path

---

## Current Project Status

### Completed
- Project structure initialization
- Knowledge base setup

### In Progress
- Godot project configuration
- Core class definitions

### Next Steps
1. Configure Godot project settings (viewport, resolution, stretch)
2. Create core GDScript classes
3. Implement shader effects
4. Build initial game scene

---

## File Structure
```
PTDG/
├── docs/
│   ├── knowledge_base/     # Project documentation and guides
│   └── design/             # Design documents and specs
├── scripts/
│   ├── enemies/            # Enemy (Glitcher) scripts
│   ├── towers/             # Tower (Defender) scripts
│   ├── managers/           # Game management scripts
│   ├── ui/                 # UI scripts
│   └── shaders/            # Shader helper scripts
├── scenes/
│   ├── enemies/            # Enemy scene files
│   ├── towers/             # Tower scene files
│   ├── levels/             # Level/map scenes
│   └── ui/                 # UI scenes
├── assets/
│   ├── sprites/            # Image assets
│   ├── audio/              # Sound effects and music
│   └── fonts/              # Fonts for UI
└── shaders/                # Shader files (.gdshader)
```
