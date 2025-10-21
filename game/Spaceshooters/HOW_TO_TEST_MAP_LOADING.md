# How to Test Map Loading in Godot

## 🎮 Quick Test - 3 Simple Ways

### Method 1: Test Individual Map (Easiest)

1. **Open Godot** at `d:\GalacticCombat\`
2. **In FileSystem panel** (bottom-left), navigate to `res://maps/`
3. **Double-click `AsteroidField.tscn`** to open the map scene
4. **Press F6** (or click the "Play Scene" button at top-right)
5. **Map should load and display!**

✅ If you see the asteroid field background and can move around, it works!

---

### Method 2: Test from Main Menu (Realistic Test)

1. **Open Godot** at `d:\GalacticCombat\`
2. **Press F5** (or click "Play" button) to run the whole game
3. **In the main menu**, look for map selection or lobby
4. **Select "Asteroid Field" map**
5. **Click "Play" or "Start Game"**
6. **Map should load!**

---

### Method 3: Test MapSystem Script (Advanced)

#### Open the Map Scene

1. **Open Godot**
2. **FileSystem** → `res://maps/AsteroidField.tscn`
3. **Click on the root node** in Scene panel
4. **In Inspector** (right side), verify the script is attached
5. **Press F6** to test

#### Test Map Loading Code

Create a simple test scene:

1. **Scene** → **New Scene** → **2D Scene**
2. **Add a Button node** as child
3. **Attach this script to Button:**

```gdscript
extends Button

func _ready():
    text = "Load Asteroid Field"
    pressed.connect(_on_button_pressed)

func _on_button_pressed():
    print("Loading map...")
    get_tree().change_scene_to_file("res://maps/AsteroidField.tscn")
```

4. **Save as `MapTest.tscn`**
5. **Run this scene with F6**
6. **Click the button** - map should load!

---

## 🔧 Testing MapSystem.gd Integration

### Check if MapSystem is Working

1. **Open `MapSystem.gd`** (double-click in FileSystem)
2. **Look for the `available_maps` array:**

```gdscript
var available_maps = [
    {
        "name": "Asteroid Field",
        "scene_path": "res://maps/AsteroidField.tscn",
        "description": "Navigate through dangerous asteroid fields",
        "difficulty": "Medium"
    }
]
```

3. **Make sure your map is listed here**

### Test Map Loading Function

Add this test code to your main scene or a test script:

```gdscript
extends Node2D

func _ready():
    # Wait 2 seconds then load map
    await get_tree().create_timer(2.0).timeout
    test_map_loading()

func test_map_loading():
    print("Testing map loading...")
    
    # Method 1: Direct scene change
    get_tree().change_scene_to_file("res://maps/AsteroidField.tscn")
    
    # Method 2: Using MapSystem (if autoload)
    # MapSystem.load_map("Asteroid Field")
```

---

## 🎯 Complete Test Workflow

### Step 1: Open Your Project

```
1. Launch Godot 4.x
2. Open "d:\GalacticCombat"
3. Wait for asset import (first time only)
```

### Step 2: Verify Map Files Exist

```
FileSystem Panel → maps folder
✓ AsteroidField.tscn (scene)
✓ AsteroidField.gd (script)
```

### Step 3: Test Map Directly

```
1. Double-click AsteroidField.tscn
2. Press F6 (Play Scene)
3. Should see: Asteroid background + player can spawn
```

### Step 4: Test from Lobby

```
1. Open Lobby.tscn
2. Press F6 to test lobby
3. Select "Asteroid Field" from map list
4. Click "Start Game"
5. Map should load with players
```

### Step 5: Test Multiplayer Map Loading

```
1. Run game (F5)
2. Host a game
3. Select map
4. Start game
5. Map loads for all players
```

---

## 🐛 Troubleshooting

### Map Doesn't Load

**Check Console for Errors:**
- Bottom panel → "Output" tab
- Look for red error messages

**Common Issues:**

1. **"Cannot load scene" error**
   - Fix: Check file path is correct: `res://maps/AsteroidField.tscn`

2. **"Invalid scene" error**  
   - Fix: Open scene in editor, save it again

3. **Black screen**
   - Fix: Map might be loading but has no visible content
   - Add a ColorRect or background sprite

4. **"Resource not found"**
   - Fix: Scene file might be in wrong location
   - Verify file exists in `d:\GalacticCombat\maps\`

### Map Loads but Looks Wrong

1. **No background visible:**
   - Add a Sprite2D with background texture
   - Or add ParallaxBackground

2. **Player can't spawn:**
   - Add a Marker2D or Node2D for spawn point
   - Name it "PlayerSpawnPoint"

3. **No collision:**
   - Add StaticBody2D with CollisionShape2D for boundaries

---

## 📝 Debug Script for Testing

Create `MapLoadTest.gd`:

```gdscript
extends Node2D

func _ready():
    print("=== MAP LOAD TEST STARTED ===")
    
    # Test 1: Check if map file exists
    var map_path = "res://maps/AsteroidField.tscn"
    if ResourceLoader.exists(map_path):
        print("✓ Map file found: " + map_path)
    else:
        print("✗ Map file NOT found: " + map_path)
        return
    
    # Test 2: Try to load the map resource
    var map_scene = load(map_path)
    if map_scene:
        print("✓ Map scene loaded successfully")
    else:
        print("✗ Failed to load map scene")
        return
    
    # Test 3: Try to instance the map
    var map_instance = map_scene.instantiate()
    if map_instance:
        print("✓ Map instanced successfully")
        print("  Map type: " + str(map_instance.get_class()))
        print("  Map children: " + str(map_instance.get_child_count()))
    else:
        print("✗ Failed to instance map")
        return
    
    # Test 4: Load the map for real
    print("Loading map in 2 seconds...")
    await get_tree().create_timer(2.0).timeout
    get_tree().change_scene_to_file(map_path)
    
    print("=== MAP LOAD TEST COMPLETE ===")

func _input(event):
    # Press SPACE to reload map
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_SPACE:
            print("Reloading map...")
            get_tree().reload_current_scene()
```

**To use:**
1. Create new scene (2D Scene)
2. Attach this script to root node
3. Run scene with F6
4. Check Output panel for test results

---

## ✅ Success Checklist

Map loading works if you can:

- [ ] Open map scene in Godot editor
- [ ] Run map scene with F6 (no errors)
- [ ] See background/environment
- [ ] Load map from main menu
- [ ] Load map from lobby
- [ ] Map loads in multiplayer
- [ ] No error messages in console
- [ ] Players can spawn on the map
- [ ] Game runs smoothly on the map

---

## 🎮 Quick Test Commands

**In Godot Script Editor Console (bottom panel):**

```gdscript
# Test 1: Check if map exists
print(ResourceLoader.exists("res://maps/AsteroidField.tscn"))

# Test 2: Load map immediately
get_tree().change_scene_to_file("res://maps/AsteroidField.tscn")

# Test 3: Check available maps (if MapSystem is autoload)
print(MapSystem.available_maps)
```

---

## 🚀 Next Steps After Successful Test

1. **Add more maps** following the same pattern
2. **Add map preview images** for selection screen
3. **Add map-specific music** and sound effects  
4. **Test with multiple players** in multiplayer
5. **Add map voting system** in lobby
6. **Create map rotation** for continuous gameplay

---

## 📚 Related Guides

- `HOW_TO_CREATE_MAPS_IN_GODOT.md` - Create new maps
- `HOW_TO_ADD_MAPS.md` - Add maps to the system
- `MULTIPLAYER_LOBBY_COMPLETE_IMPLEMENTATION.md` - Multiplayer setup
- `START_HERE_FINAL.md` - General getting started

**Happy map testing! 🗺️**
