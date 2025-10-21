# Difficulty System - Complete Implementation Guide

## ✅ COMPLETED

1. **DifficultyManager.gd** - Created with 4 difficulty levels
2. **Added to Autoload** - Globally accessible as `DifficultyManager`

## 🎮 Difficulty Levels

### Easy
- **Health**: 5 hearts
- **Enemy Health**: 30% weaker
- **Enemy Speed**: 20% slower
- **Enemy Shooting**: 50% slower
- **Spawn Rate**: 30% slower
- **Score Multiplier**: 0.8x
- **Description**: "Relaxed gameplay, perfect for beginners"

### Normal (Default)
- **Health**: 3 hearts
- **Enemy Health**: Normal
- **Enemy Speed**: Normal
- **Enemy Shooting**: Normal
- **Spawn Rate**: Normal
- **Score Multiplier**: 1.0x
- **Description**: "Balanced challenge for most players"

### Hard
- **Health**: 2 hearts
- **Enemy Health**: 30% stronger
- **Enemy Speed**: 30% faster
- **Enemy Shooting**: 30% faster
- **Spawn Rate**: 20% faster
- **Score Multiplier**: 1.5x
- **Description**: "Intense combat for experienced pilots"

### Insane
- **Health**: 1 heart
- **Enemy Health**: 50% stronger
- **Enemy Speed**: 50% faster
- **Enemy Shooting**: 50% faster (2x as fast!)
- **Spawn Rate**: 40% faster
- **Enemy Damage**: 2x damage
- **Score Multiplier**: 2.0x
- **Description**: "Brutal difficulty for masters only!"

## 🔧 How to Add Difficulty Selection to Main Menu

### Step 1: Add Difficulty Selection Scene

In Godot, add to MainMenu.tscn:

```
VBoxContainer
├── TitleLabel
├── PlayButton
├── DifficultyButton  <-- ADD THIS
├── OnlineButton
├── SettingsButton
├── MapsButton
└── QuitButton
```

### Step 2: Connect Difficulty Button in MainMenu.gd

Add this function to MainMenu.gd:

```gdscript
func _on_difficulty_button_pressed():
	# Show difficulty selection popup
	show_difficulty_menu()

func show_difficulty_menu():
	# Create popup panel
	var popup = Panel.new()
	popup.size = Vector2(400, 300)
	popup.position = Vector2(440, 210)  # Center
	add_child(popup)
	
	var vbox = VBoxContainer.new()
	popup.add_child(vbox)
	
	var title = Label.new()
	title.text = "Select Difficulty"
	vbox.add_child(title)
	
	# Add button for each difficulty
	for diff in DifficultyManager.get_all_difficulties():
		var btn = Button.new()
		btn.text = diff["name"] + ": " + diff["description"]
		btn.pressed.connect(_on_difficulty_selected.bind(diff["id"], popup))
		vbox.add_child(btn)

func _on_difficulty_selected(difficulty_id, popup):
	DifficultyManager.set_difficulty(difficulty_id)
	popup.queue_free()
	print("Difficulty set to: ", DifficultyManager.get_difficulty_name())
```

### Step 3: Update GameManager to Use Difficulty

Add to GameManager.gd `_ready()`:

```gdscript
func _ready():
	# Apply difficulty settings
	apply_difficulty_settings()
	
	# Rest of _ready code...

func apply_difficulty_settings():
	# Set player health based on difficulty
	if player:
		player.health = DifficultyManager.get_setting("player_health")
		player.health_changed.emit(player.health)
	
	# Adjust spawn rate
	spawn_interval = spawn_interval * DifficultyManager.get_setting("spawn_rate_multiplier")
```

### Step 4: Update Enemy Spawning

In GameManager.gd `spawn_enemy()`:

```gdscript
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# Apply difficulty multipliers
	enemy.health = int(enemy.health * DifficultyManager.get_setting("enemy_health_multiplier"))
	enemy.speed = enemy.speed * DifficultyManager.get_setting("enemy_speed_multiplier")
	enemy.shoot_cooldown = enemy.shoot_cooldown * DifficultyManager.get_setting("enemy_shoot_rate_multiplier")
	
	# Rest of spawn code...
```

### Step 5: Update Score Calculation

In GameManager.gd `_on_enemy_destroyed()`:

```gdscript
func _on_enemy_destroyed(points: int):
	var score_multiplier = DifficultyManager.get_setting("score_multiplier")
	var adjusted_points = int(points * score_multiplier)
	score += adjusted_points
	score_changed.emit(score)
	ui.update_score(score)
```

## 🎨 UI Elements to Add

### Difficulty Display in Game
Add a label in UI.gd to show current difficulty:

```gdscript
@onready var difficulty_label = $DifficultyLabel if has_node("DifficultyLabel") else null

func _ready():
	if difficulty_label:
		difficulty_label.text = "Difficulty: " + DifficultyManager.get_difficulty_name()
```

### Difficulty Indicator Colors
```gdscript
var difficulty_colors = {
	DifficultyManager.Difficulty.EASY: Color(0, 1, 0),  # Green
	DifficultyManager.Difficulty.NORMAL: Color(0, 0.5, 1),  # Blue
	DifficultyManager.Difficulty.HARD: Color(1, 0.5, 0),  # Orange
	DifficultyManager.Difficulty.INSANE: Color(1, 0, 0)  # Red
}
```

## 📊 Testing Each Difficulty

### Easy Mode Test
- Spawn with 5 hearts
- Enemies move slower
- Easier to dodge bullets
- More forgiving gameplay

### Normal Mode Test
- Standard 3 hearts
- Balanced challenge
- Default experience

### Hard Mode Test
- Only 2 hearts
- Enemies faster and tougher
- More bullets to dodge
- Requires skill

### Insane Mode Test
- ONE HEART ONLY
- Enemies very fast and strong
- Enemy bullets everywhere
- Any hit = game over
- For expert players only!

## 🔥 Quick Implementation Checklist

- [x] Create DifficultyManager.gd
- [x] Add to project autoload
- [ ] Add difficulty button to MainMenu
- [ ] Create difficulty selection popup
- [ ] Update GameManager._ready() to apply settings
- [ ] Update enemy spawning with multipliers
- [ ] Update score calculation with multiplier
- [ ] Add difficulty label to game UI
- [ ] Test all 4 difficulties
- [ ] Balance difficulty values if needed

## 💡 Future Enhancements

- **Difficulty Badges**: Earn badges for completing waves on Hard/Insane
- **Leaderboards**: Separate leaderboards per difficulty
- **Difficulty Rewards**: Bonus currency/unlocks for harder difficulties
- **Adaptive Difficulty**: Auto-adjust based on player performance
- **Custom Difficulty**: Let players create custom settings

## 🎯 How Players Will Use It

1. **Launch Game** → See Main Menu
2. **Click "Difficulty" Button** → Popup appears
3. **Choose Difficulty** → Easy/Normal/Hard/Insane
4. **Click "Play"** → Game starts with chosen difficulty
5. **Notice Changes** → Health, enemy behavior, score multiplier

The system is ready - just needs the UI buttons connected!
