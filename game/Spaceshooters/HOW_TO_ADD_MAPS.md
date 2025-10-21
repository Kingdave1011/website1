# 🗺️ How To Add Maps To Galactic Combat

## Quick Method: Change Backgrounds

The simplest way to add "maps" is to change the background image for different levels.

---

## Method 1: Simple Background Swap (Easiest!)

### In Main.tscn (your gameplay scene):

1. **Add a Sprite2D node** for background
2. **Set different textures** based on level/score

### In GameManager.gd add:

```gdscript
var current_map = 0
var map_backgrounds = [
	"res://backgrounds/space.png",      # Map 1
	"res://backgrounds/nebula.png",     # Map 2  
	"res://backgrounds/asteroid.png",   # Map 3
]

func change_map():
	current_map = (current_map + 1) % map_backgrounds.size()
	$Background.texture = load(map_backgrounds[current_map])

func _on_level_complete():
	change_map()  # Switch to next map
```

---

## Method 2: Different Enemy Patterns Per Map

Make each map feel unique by changing enemy behavior:

```gdscript
func spawn_enemies_for_current_map():
	match current_map:
		0:  # Space Station
			spawn_pattern_corridors()
		1:  # Nebula
			spawn_pattern_clouds()
		2:  # Asteroid Field
			spawn_pattern_rocks()

func spawn_pattern_corridors():
	# Spawn in straight lines
	for i in range(5):
		spawn_enemy(Vector2(i * 100, 50))

func spawn_pattern_clouds():
	# Random scattered
	for i in range(10):
		var pos = Vector2(randf() * 1000, randf() * 300)
		spawn_enemy(pos)
```

---

## Method 3: Map Selection Menu (More Complex)

If you want players to choose maps:

### 1. Create MapData.gd autoload:

```gdscript
extends Node

var maps = {
	"space": {"name": "Space Station", "bg": "res://bg1.png"},
	"nebula": {"name": "Nebula Cloud", "bg": "res://bg2.png"},
	"asteroids": {"name": "Asteroid Field", "bg": "res://bg3.png"}
}

var selected_map = "space"

func select_map(map_id):
	selected_map = map_id
```

### 2. Add to project.godot autoloads:
```
MapData="*res://MapData.gd"
```

### 3. In Main.tscn use selected map:
```gdscript
func _ready():
	var map = MapData.maps[MapData.selected_map]
	$Background.texture = load(map["bg"])
```

---

## 🎨 Creating Different Backgrounds

**You can:**
- Use solid colors (easiest)
- Find free space backgrounds online
- Use Godot's ColorRect with gradients
- Generate procedural backgrounds

**Simple example:**
```gdscript
# No image needed - just colors!
func set_map_color(map_id):
	match map_id:
		0:
			$ColorRect.color = Color(0.05, 0.05, 0.15)  # Dark blue
		1:
			$ColorRect.color = Color(0.15, 0.05, 0.25)  # Purple  
		2:
			$ColorRect.color = Color(0.1, 0.1, 0.1)     # Gray
```

---

## ✅ Start Simple!

**Recommendation:** Use Method 1 (background swap)
- Easy to implement
- No new systems needed
- Works immediately
- Can expand later

**Your game is working - keep it simple and add features gradually!**
