# 🎮 HEALTH BAR SETUP GUIDE

Complete guide for creating and integrating health bars in your game.

---

## ✅ FILES CREATED

- `HealthBar.gd` - Main health bar script with animations and color transitions

---

## 🔧 SETUP INSTRUCTIONS

### PART 1: Create Player Health Bar Scene (10 minutes)

#### Step 1: Create New Scene
1. In Godot, click **Scene** → **New Scene**
2. Select **User Interface** as root node type
3. Name the root node: `HealthBar`
4. Click **Create**

#### Step 2: Add Child Nodes

**Add these nodes as children of HealthBar:**

1. **Background** (ColorRect)
   - Position: (0, 0)
   - Size: (200, 30)
   - Color: Black with alpha 0.7 → `Color(0, 0, 0, 0.7)`

2. **Fill** (ColorRect)
   - Position: (2, 2)
   - Size: (196, 26)
   - Color: Green → `Color(0.2, 0.8, 0.2, 1.0)`

3. **Border** (ColorRect)
   - Position: (0, 0)
   - Size: (200, 30)
   - Color: White
   - **In Inspector:** Scroll to **Theme Overrides** → **Styles**
   - Click **Empty** → **New StyleBoxFlat**
   - Click the StyleBoxFlat
   - Set **Draw Center**: OFF (uncheck)
   - Set **Border Width**: Top: 2, Right: 2, Bottom: 2, Left: 2
   - Set **Border Color**: White

4. **Label** (Label)
   - Position: (0, 0)
   - Size: (200, 30)
   - Text: "100 / 100"
   - Horizontal Alignment: Center
   - Vertical Alignment: Center
   - **Theme Overrides** → **Font Size**: 14
   - **Theme Overrides** → **Font Outline Size**: 2
   - **Theme Overrides** → **Font Outline Color**: Black

#### Step 3: Attach Script
1. Select the root **HealthBar** node
2. Click the script icon (or press Ctrl+A)
3. Click **Load**
4. Navigate to and select `HealthBar.gd`
5. Click **Open**

#### Step 4: Set Node Paths (IMPORTANT!)
The script expects these exact node names. Verify your scene tree looks like:
```
HealthBar (Control)
├── Background (ColorRect)
├── Fill (ColorRect)
├── Border (ColorRect)
└── Label (Label)
```

#### Step 5: Configure Control Node
1. Select root **HealthBar** node
2. In **Inspector** → **Layout**:
   - Set **Custom Minimum Size**: (200, 30)
3. In **Inspector** → **Control**:
   - Set **Size**: (200, 30)

#### Step 6: Save Scene
1. Press **Ctrl+S** or **Scene** → **Save Scene**
2. Save as: `HealthBar.tscn`
3. Save in: `res://` (root directory)

---

### PART 2: Integrate with Player (15 minutes)

#### Option A: Add to Main Game Scene

1. Open your main game scene (e.g., `Main.tscn`)
2. Find your UI/HUD node (usually a CanvasLayer)
3. Right-click the UI node → **Instance Child Scene**
4. Select `HealthBar.tscn`
5. Position it in the top-left corner:
   - Position: (20, 20)
6. Name the instance: `PlayerHealthBar`

#### Option B: Add Directly to Player

1. Open `Player.tscn`
2. Add a **CanvasLayer** child to Player root
3. Instance `HealthBar.tscn` as child of CanvasLayer
4. Name it: `HealthBar`

#### Connect to Player Health

**In your GameManager.gd or Main.gd:**

```gdscript
@onready var player = $Player
@onready var health_bar = $UI/PlayerHealthBar

func _ready():
    # Connect player health signal
    if player.has_signal("health_changed"):
        player.health_changed.connect(_on_player_health_changed)
    
    # Set initial health
    health_bar.set_health(player.health, player.health)

func _on_player_health_changed(new_health: int):
    health_bar.set_health(new_health)
```

**Make sure Player.gd has:**
```gdscript
signal health_changed(new_health)

@export var health: int = 100

func take_damage(amount: int):
    health -= amount
    health_changed.emit(health)
    
    if health <= 0:
        die()
```

---

### PART 3: Create Enemy Health Bars (20 minutes)

Enemy health bars should be smaller and attached to each enemy.

#### Step 1: Create EnemyHealthBar Scene

1. **Duplicate HealthBar.tscn**
   - Right-click `HealthBar.tscn` in FileSystem
   - Select **Duplicate**
   - Rename to: `EnemyHealthBar.tscn`

2. **Open EnemyHealthBar.tscn**
3. **Modify sizes** (make it smaller):
   - Root HealthBar: Size (60, 8)
   - Background: Size (60, 8)
   - Fill: Position (1, 1), Size (58, 6)
   - Border: Size (60, 8)
   - Label: Size (60, 8), Font Size: 8

4. **Save changes**

#### Step 2: Add to Enemy Scene

1. Open `Enemy.tscn`
2. Add child node: **Control** (name it: `HealthBarContainer`)
3. Set HealthBarContainer:
   - Position: (-30, -40) (above enemy)
   - Size: (60, 8)
   - Layout → Anchors Preset: **Center**
4. Instance `EnemyHealthBar.tscn` as child of HealthBarContainer
5. Save

#### Step 3: Connect to Enemy Health

**Add to Enemy.gd:**

```gdscript
@onready var health_bar = $HealthBarContainer/EnemyHealthBar

func _ready():
    # ... existing code ...
    
    # Initialize health bar
    if health_bar:
        health_bar.set_health(health, health)
        health_bar.set_show_numbers(false)  # Hide numbers for enemies

func take_damage(amount: int):
    health -= amount
    
    # Update health bar
    if health_bar:
        health_bar.set_health(health)
    
    # ... rest of existing code ...
```

---

### PART 4: Create Boss Health Bar (15 minutes)

Boss health bars should be large and positioned at the top of the screen.

#### Step 1: Create BossHealthBar Scene

1. **Duplicate HealthBar.tscn**
2. Rename to: `BossHealthBar.tscn`
3. Open it and modify:
   - Root size: (600, 40)
   - Background: Size (600, 40)
   - Fill: Position (3, 3), Size (594, 34)
   - Border: Size (600, 40), Border Width: 3
   - Label: Size (600, 40), Font Size: 20

4. **Add Boss Name Label**:
   - Add new **Label** child named `BossName`
   - Position: (0, -25)
   - Size: (600, 20)
   - Text: "BOSS NAME"
   - Horizontal Alignment: Center
   - Font Size: 16
   - Font Color: Red

5. Save

#### Step 2: Update Script for Boss

**Create BossHealthBar.gd** (extends HealthBar.gd):

```gdscript
extends "res://HealthBar.gd"

@onready var boss_name_label = $BossName

func set_boss_name(boss_name: String):
    if boss_name_label:
        boss_name_label.text = boss_name

func _ready():
    super._ready()
    # Boss bars always show numbers
    set_show_numbers(true)
```

#### Step 3: Position in UI

1. In your main game scene
2. Add BossHealthBar instance to UI
3. Position at top-center:
   - Anchor: Top Center
   - Position: (-300, 20)

---

## 🎨 CUSTOMIZATION OPTIONS

### Change Colors

**In HealthBar.gd, modify `update_color()` function:**

```gdscript
func update_color():
    var health_percent = float(current_health) / float(max_health)
    
    if health_percent > 0.6:
        fill.color = Color(0, 1, 0, 1)  # Bright Green
    elif health_percent > 0.3:
        fill.color = Color(1, 1, 0, 1)  # Yellow
    elif health_percent > 0.15:
        fill.color = Color(1, 0.5, 0, 1)  # Orange
    else:
        fill.color = Color(1, 0, 0, 1)  # Red
```

### Add Shield Bar

**Add second ColorRect for shield:**

```gdscript
@onready var shield_fill = $ShieldFill

func set_shield(shield: int, max_shield: int):
    if shield_fill:
        var shield_percent = float(shield) / float(max_shield)
        shield_fill.size.x = size.x * shield_percent
        shield_fill.color = Color(0.2, 0.6, 1.0, 0.5)  # Blue transparent
```

### Smooth Damage/Healing Animation

The health bar already includes smooth animations! To adjust:

```gdscript
# In animate_health_change(), change the duration:
tween.tween_property(fill, "size:x", width * health_percent_to, 0.5)  # Slower
# Or
tween.tween_property(fill, "size:x", width * health_percent_to, 0.1)  # Faster
```

---

## 🔌 INTEGRATION CHECKLIST

### Player Health Bar
- [x] Created HealthBar.gd script
- [ ] Created HealthBar.tscn scene
- [ ] Added to game UI
- [ ] Connected to player health_changed signal
- [ ] Tested damage and healing

### Enemy Health Bars
- [ ] Created EnemyHealthBar.tscn
- [ ] Added to Enemy.tscn
- [ ] Connected to enemy health
- [ ] Positioned above enemies
- [ ] Tested with multiple enemies

### Boss Health Bar
- [ ] Created BossHealthBar.tscn
- [ ] Created BossHealthBar.gd
- [ ] Added to UI (top center)
- [ ] Set boss name function
- [ ] Tested with boss enemy

---

## 🐛 TROUBLESHOOTING

### Health Bar Not Showing
- Check that HealthBar is in UI/CanvasLayer
- Verify Z-index is above other UI elements
- Check that Control node visibility is ON

### Health Bar Not Updating
- Verify health_changed signal is connected
- Check that Player.gd emits health_changed signal
- Add print statements to debug:
  ```gdscript
  func _on_player_health_changed(new_health: int):
      print("Health changed to: ", new_health)
      health_bar.set_health(new_health)
  ```

### Colors Not Changing
- Verify Fill node name is exactly "Fill"
- Check update_color() is being called
- Ensure Fill is a ColorRect, not something else

### Label Not Showing
- Check Label node exists and is visible
- Verify show_numbers is true
- Check font size isn't too small
- Verify Label is above Background in node tree

---

## 🎮 ADVANCED FEATURES

### Add Health Regeneration Visual

```gdscript
func start_regeneration():
    var tween = create_tween()
    tween.tween_property(fill, "modulate", Color(0.5, 1, 0.5), 0.5)
    tween.tween_property(fill, "modulate", Color.WHITE, 0.5)
    tween.set_loops()

func stop_regeneration():
    fill.modulate = Color.WHITE
```

### Add Damage Flash Effect

```gdscript
func flash_damage():
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color(1, 0.5, 0.5), 0.1)
    tween.tween_property(self, "modulate", Color.WHITE, 0.1)
```

### Multiple Health Segments

```gdscript
# For games with segmented health (like hearts)
func create_segments(segment_count: int):
    for i in range(segment_count):
        var segment = ColorRect.new()
        segment.color = Color.GREEN
        segment.size = Vector2(size.x / segment_count - 2, size.y - 4)
        segment.position = Vector2(i * (size.x / segment_count) + 2, 2)
        add_child(segment)
```

---

## 📝 QUICK REFERENCE

### Key Functions

```gdscript
# Set health (with optional max health)
health_bar.set_health(50, 100)

# Toggle number display
health_bar.set_show_numbers(false)

# Toggle animations
health_bar.set_animate_changes(false)

# Direct callback (alternative to signals)
health_bar._on_health_changed(new_value)
```

### Signal Connection

```gdscript
# From parent node
player.health_changed.connect(health_bar._on_health_changed)

# Or custom handler
player.health_changed.connect(func(hp): health_bar.set_health(hp))
```

---

## ✨ DONE!

Your health bar system is now ready! Test it by:
1. Running the game
2. Taking damage (enemy collision)
3. Watching the smooth color transitions
4. Checking the critical health pulse effect

For more customization, check the HealthBar.gd script comments!

🎮 Happy Gaming! 🚀
