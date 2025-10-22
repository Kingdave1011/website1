# Visual Quality & Data Persistence Guide

This guide covers advanced improvements for your Space Shooter game:
1. **Enhanced Visual Presentation**
2. **Player Data Persistence**
3. **Supabase Integration**
4. **Multi-Platform Deployment**

---

## Part 1: Enhanced Visual Presentation

### High-Quality Graphics Settings

Update `project.godot` settings for better visuals:

```ini
[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/mode=2
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[rendering]
textures/canvas_textures/default_texture_filter=2  # Linear with mipmaps
renderer/rendering_method="gl_compatibility"
anti_aliasing/quality/msaa_2d=2  # 4x MSAA
anti_aliasing/quality/screen_space_aa=1  # FXAA
environment/defaults/default_clear_color=Color(0, 0, 0.02, 1)
```

### Create Enhanced Visual Effects Manager

Create `VisualEffectsManager.gd`:

```gdscript
extends Node

# Particle effects
var explosion_particles = preload("res://effects/ExplosionParticles.tscn")
var bullet_trail_particles = preload("res://effects/BulletTrail.tscn")
var engine_glow_particles = preload("res://effects/EngineGlow.tscn")

func _ready():
	# Set up post-processing effects
	setup_bloom()
	setup_glow()

func setup_bloom():
	var world_env = WorldEnvironment.new()
	var env = Environment.new()
	
	# Bloom settings for glow effects
	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.glow_strength = 1.2
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	
	world_env.environment = env
	get_tree().root.add_child(world_env)

func setup_glow():
	# Add HDR tone mapping
	var env = get_viewport().get_world_2d().environment
	if env:
		env.tonemap_mode = Environment.TONE_MAPPER_ACES
		env.tonemap_exposure = 1.2
		env.tonemap_white = 1.5

func create_explosion(position: Vector2, size: float = 1.0):
	var explosion = explosion_particles.instantiate()
	explosion.global_position = position
	explosion.scale = Vector2(size, size)
	get_tree().root.add_child(explosion)
	
	# Screen shake
	var camera = get_viewport().get_camera_2d()
	if camera:
		apply_camera_shake(camera, 15 * size, 0.3)
	
	# Slow motion effect
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.1).timeout
	Engine.time_scale = 1.0

func apply_camera_shake(camera: Camera2D, intensity: float, duration: float):
	var original_offset = camera.offset
	var shake_timer = 0.0
	
	while shake_timer < duration:
		shake_timer += get_process_delta_time()
		var shake_amount = intensity * (1.0 - shake_timer / duration)
		camera.offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		await get_tree().process_frame
	
	camera.offset = original_offset

func add_bullet_trail(bullet: Node2D):
	var trail = bullet_trail_particles.instantiate()
	bullet.add_child(trail)

func add_engine_glow(ship: Node2D):
	var glow = engine_glow_particles.instantiate()
	glow.position = Vector2(0, 20)  # Behind ship
	ship.add_child(glow)
```

### Particle System Templates

Create `effects/ExplosionParticles.tscn` with CPUParticles2D:

```gdscript
# ExplosionParticles.gd
extends CPUParticles2D

func _ready():
	# Explosion settings
	emitting = true
	one_shot = true
	explosiveness = 1.0
	lifetime = 0.8
	amount = 50
	
	# Visual properties
	texture = create_particle_texture()
	scale_amount_min = 0.5
	scale_amount_max = 2.0
	
	# Colors (fire to smoke)
	color_ramp = Gradient.new()
	color_ramp.add_point(0.0, Color(1, 1, 0.5, 1))  # Bright yellow
	color_ramp.add_point(0.3, Color(1, 0.5, 0, 1))  # Orange
	color_ramp.add_point(0.7, Color(0.3, 0.1, 0, 0.5))  # Dark red
	color_ramp.add_point(1.0, Color(0.1, 0.1, 0.1, 0))  # Fade to smoke
	
	# Physics
	direction = Vector2.UP
	spread = 180
	initial_velocity_min = 100
	initial_velocity_max = 300
	gravity = Vector2(0, 50)
	
	# Auto-delete when done
	await get_tree().create_timer(lifetime + 0.5).timeout
	queue_free()

func create_particle_texture() -> Texture2D:
	var img = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	return ImageTexture.create_from_image(img)
```

### Enhanced Ship Shaders

Create `shaders/ShipGlow.gdshader`:

```glsl
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	vec4 glow = glow_color * glow_intensity * pulse;
	COLOR = tex_color + glow * tex_color.a;
}
```

### Menu Visual Enhancements

Create `EnhancedMenuSystem.gd`:

```gdscript
extends Control

func _ready():
	# Add animated background
	add_starfield_background()
	
	# Add menu animations
	animate_menu_appearance()
	
	# Style all buttons
	style_buttons()

func add_starfield_background():
	var starfield = CPUParticles2D.new()
	starfield.emitting = true
	starfield.amount = 200
	starfield.lifetime = 10.0
	starfield.preprocess = 5.0
	
	# Starfield settings
	starfield.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	starfield.emission_rect_extents = get_viewport_rect().size
	starfield.direction = Vector2(0, 1)
	starfield.spread = 5
	starfield.gravity = Vector2(0, 20)
	starfield.initial_velocity_min = 10
	starfield.initial_velocity_max = 50
	
	# Star appearance
	var star_texture = create_star_texture()
	starfield.texture = star_texture
	starfield.scale_amount_min = 0.5
	starfield.scale_amount_max = 1.5
	
	add_child(starfield)
	move_child(starfield, 0)  # Send to back

func create_star_texture() -> Texture2D:
	var img = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.8))
	return ImageTexture.create_from_image(img)

func animate_menu_appearance():
	# Fade in animation
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Slide in buttons
	for child in get_children():
		if child is Button:
			child.position.x -= 100
			child.modulate.a = 0
			var btn_tween = create_tween()
			btn_tween.set_trans(Tween.TRANS_BACK)
			btn_tween.set_ease(Tween.EASE_OUT)
			btn_tween.tween_property(child, "position:x", child.position.x + 100, 0.6)
			btn_tween.parallel().tween_property(child, "modulate:a", 1.0, 0.6)

func style_buttons():
	for child in get_children():
		if child is Button:
			# Modern button style
			var style_normal = StyleBoxFlat.new()
			style_normal.bg_color = Color(0.15, 0.15, 0.2, 0.9)
			style_normal.border_width_all = 2
			style_normal.border_color = Color(0.3, 0.6, 1.0, 0.8)
			style_normal.corner_radius_all = 8
			style_normal.shadow_size = 4
			style_normal.shadow_color = Color(0, 0, 0, 0.5)
			
			var style_hover = StyleBoxFlat.new()
			style_hover.bg_color = Color(0.2, 0.25, 0.35, 1.0)
			style_hover.border_width_all = 2
			style_hover.border_color = Color(0.4, 0.7, 1.0, 1.0)
			style_hover.corner_radius_all = 8
			style_hover.shadow_size = 6
			style_hover.shadow_color = Color(0.3, 0.6, 1.0, 0.3)
			
			child.add_theme_stylebox_override("normal", style_normal)
			child.add_theme_stylebox_override("hover", style_hover)
			child.add_theme_font_size_override("font_size", 24)
			
			# Add hover animation
			child.mouse_entered.connect(func(): animate_button_hover(child, true))
			child.mouse_exited.connect(func(): animate_button_hover(child, false))

func animate_button_hover(button: Button, is_hovering: bool):
	var tween = create_tween()
	var target_scale = Vector2(1.1, 1.1) if is_hovering else Vector2.ONE
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, 0.2)
```

---

## Part 2: Player Data Persistence

### Create Save/Load System

Create `SaveSystem.gd`:

```gdscript
extends Node

const SAVE_FILE = "user://player_data.save"

# Player data structure
var player_data = {
	"player_name": "Player",
	"level": 1,
	"xp": 0,
	"total_score": 0,
	"high_score": 0,
	"credits": 0,
	"selected_ship": "default",
	"unlocked_ships": ["default"],
	"unlocked_skins": [],
	"settings": {
		"music_volume": 0.7,
		"sfx_volume": 0.8,
		"show_fps": false,
		"difficulty": "normal"
	},
	"statistics": {
		"games_played": 0,
		"total_kills": 0,
		"total_deaths": 0,
		"total_playtime": 0,
		"highest_wave": 0
	},
	"achievements": [],
	"last_played": ""
}

func _ready():
	load_game()

func save_game():
	player_data["last_played"] = Time.get_datetime_string_from_system()
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(player_data, "\t")
		file.store_string(json_string)
		file.close()
		print("✅ Game saved successfully")
		return true
	else:
		push_error("❌ Failed to save game")
		return false

func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		print("ℹ️ No save file found, using default data")
		save_game()  # Create initial save
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var loaded_data = json.get_data()
			if typeof(loaded_data) == TYPE_DICTIONARY:
				# Merge loaded data with defaults (in case new fields were added)
				merge_data(player_data, loaded_data)
				print("✅ Game loaded successfully")
				return true
		
		push_error("❌ Failed to parse save file")
	else:
		push_error("❌ Failed to open save file")
	
	return false

func merge_data(target: Dictionary, source: Dictionary):
	for key in source:
		if target.has(key):
			if typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
				merge_data(target[key], source[key])
			else:
				target[key] = source[key]

# Convenience functions
func get_player_name() -> String:
	return player_data["player_name"]

func set_player_name(name: String):
	player_data["player_name"] = name
	save_game()

func get_level() -> int:
	return player_data["level"]

func add_xp(amount: int):
	player_data["xp"] += amount
	check_level_up()
	save_game()

func check_level_up():
	var xp_needed = player_data["level"] * 100
	if player_data["xp"] >= xp_needed:
		player_data["level"] += 1
		player_data["xp"] -= xp_needed
		# Signal level up
		get_tree().call_group("ui", "on_level_up", player_data["level"])

func add_credits(amount: int):
	player_data["credits"] += amount
	save_game()

func unlock_ship(ship_id: String):
	if not ship_id in player_data["unlocked_ships"]:
		player_data["unlocked_ships"].append(ship_id)
		save_game()

func is_ship_unlocked(ship_id: String) -> bool:
	return ship_id in player_data["unlocked_ships"]

func update_high_score(score: int):
	if score > player_data["high_score"]:
		player_data["high_score"] = score
		save_game()
		return true
	return false

func increment_stat(stat_name: String, amount: int = 1):
	if player_data["statistics"].has(stat_name):
		player_data["statistics"][stat_name] += amount
		save_game()

func unlock_achievement(achievement_id: String):
	if not achievement_id in player_data["achievements"]:
		player_data["achievements"].append(achievement_id)
		save_game()
		# Trigger achievement popup
		get_tree().call_group("ui", "show_achievement", achievement_id)
```

### Auto-Save System

Create `AutoSaveManager.gd`:

```gdscript
extends Node

@export var auto_save_interval: float = 60.0  # Save every 60 seconds
var save_timer: float = 0

func _process(delta):
	save_timer += delta
	if save_timer >= auto_save_interval:
		save_timer = 0
		SaveSystem.save_game()
		show_save_indicator()

func show_save_indicator():
	# Show "Game Saved" message
	var label = Label.new()
	label.text = "💾 Game Saved"
	label.modulate = Color(1, 1, 1, 0)
	label.position = Vector2(
		get_viewport().get_visible_rect().size.x - 200,
		50
	)
	get_tree().root.add_child(label)
	
	# Fade in/out animation
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(label.queue_free)
```

---

## Part 3: Supabase Integration

### Set Up Supabase Client

Create `SupabaseClient.gd`:

```gdscript
extends Node

# Supabase configuration
var supabase_url = "YOUR_SUPABASE_URL"
var supabase_key = "YOUR_SUPABASE_ANON_KEY"

var http_client = HTTPClient.new()

func _ready():
	# Test connection
	test_connection()

func test_connection():
	var result = await make_request("/rest/v1/", "GET")
	if result["success"]:
		print("✅ Connected to Supabase")
	else:
		push_error("❌ Failed to connect to Supabase")

func make_request(endpoint: String, method: String, data: Dictionary = {}) -> Dictionary:
	var url = supabase_url + endpoint
	var headers = [
		"apikey: " + supabase_key,
		"Authorization: Bearer " + supabase_key,
		"Content-Type: application/json"
	]
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var body = JSON.stringify(data) if data else ""
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET if method == "GET" else HTTPClient.METHOD_POST, body)
	
	if error != OK:
		http_request.queue_free()
		return {"success": false, "error": "Request failed"}
	
	var response = await http_request.request_completed
	http_request.queue_free()
	
	var result = response[0]
	var response_code = response[1]
	var response_body = response[3]
	
	if response_code == 200 or response_code == 201:
		var json = JSON.new()
		json.parse(response_body.get_string_from_utf8())
		return {"success": true, "data": json.get_data()}
	else:
		return {"success": false, "error": "HTTP " + str(response_code)}

# Create Supabase policy (run this SQL in Supabase dashboard)
const SUPABASE_SETUP_SQL = """
-- Create player_data table
CREATE TABLE IF NOT EXISTS player_data (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT UNIQUE NOT NULL,
    player_name TEXT,
    level INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    high_score INTEGER DEFAULT 0,
    credits INTEGER DEFAULT 0,
    data JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE player_data ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "public can read player_data"
ON player_data
FOR SELECT
TO anon
USING (true);

-- Create policy for authenticated users to manage their own data
CREATE POLICY "users can manage own data"
ON player_data
FOR ALL
TO authenticated
USING (auth.uid()::text = user_id);
"""

func save_to_cloud(user_id: String, data: Dictionary) -> bool:
	var result = await make_request(
		"/rest/v1/player_data?user_id=eq." + user_id,
		"POST",
		{
			"user_id": user_id,
			"player_name": data.get("player_name", "Player"),
			"level": data.get("level", 1),
			"xp": data.get("xp", 0),
			"high_score": data.get("high_score", 0),
			"credits": data.get("credits", 0),
			"data": data
		}
	)
	return result["success"]

func load_from_cloud(user_id: String) -> Dictionary:
	var result = await make_request(
		"/rest/v1/player_data?user_id=eq." + user_id,
		"GET"
	)
	
	if result["success"] and result["data"].size() > 0:
		return result["data"][0]
	return {}
```

---

## Part 4: Multi-Platform Deployment

### Export Presets Configuration

Update `export_presets.cfg`:

```ini
[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="./builds/windows/SpaceShooterV2.exe"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/embed_pck=true
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
codesign/enable=false
application/icon="res://icon.png"
application/console_wrapper_icon=""
application/file_version=""
application/product_version=""
application/company_name="Your Company"
application/product_name="Space Shooter V2"
application/file_description=""
application/copyright=""
application/trademarks=""
ssh_remote_deploy/enabled=false

[preset.1]
name="Web"
platform="Web"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="./builds/web/index.html"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.1.options]
custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=true
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144="res://icon.png"
progressive_web_app/icon_180x180="res://icon.png"
progressive_web_app/icon_512x512="res://icon.png"
progressive_web_app/background_color=Color(0, 0, 0, 1)

[preset.2]
name="Android"
platform="Android"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="./builds/android/SpaceShooterV2.apk"
```

### Build Script

Create `build_all.sh`:

```bash
#!/bin/bash

# Space Shooter V2 - Multi-Platform Build Script

echo "🚀 Building Space Shooter V2 for all platforms..."

# Clean previous builds
rm -rf builds
mkdir -p builds/windows builds/web builds/android

# Export Windows
echo "📦 Exporting Windows build..."
godot --headless --export-release "Windows Desktop" builds/windows/SpaceShooterV2.exe

# Export Web
echo "🌐 Exporting Web build..."
godot --headless --export-release "Web" builds/web/index.html

# Export Android
echo "📱 Exporting Android build..."
godot --headless --export-release "Android" builds/android/SpaceShooterV2.apk

echo "✅ All builds complete!"
echo "📁 Windows: builds/windows/"
echo "📁 Web: builds/web/"
echo "📁 Android: builds/android/"
```

---

## Implementation Checklist

### Visual Enhancements
- [ ] Update project settings for high quality rendering
- [ ] Create VisualEffectsManager with particle systems
- [ ] Add ship glow shaders
- [ ] Enhance menu system with animations
- [ ] Add post-processing effects (bloom, glow)

### Data Persistence
- [ ] Create SaveSystem.gd autoload
- [ ] Implement AutoSaveManager
- [ ] Test save/load functionality
- [ ] Add cloud sync with Supabase

### Supabase Setup
- [ ] Create Supabase account
- [ ] Run SQL setup script
- [ ] Configure SupabaseClient with your credentials
- [ ] Test cloud save/load

### Multi-Platform
- [ ] Configure export presets
- [ ] Test Windows build
- [ ] Test Web build
- [ ] Test Android build (optional)
- [ ] Create build automation script

---

## Summary

This implementation provides:
✅ **Professional Visual Quality** - Sharp graphics, smooth animations, stunning effects
✅ **Reliable Data Persistence** - Local saves with cloud backup
✅ **Cross-Platform Support** - Windows, Web, Android ready
✅ **Modern Architecture** - Clean, maintainable code structure

Your game will now have AAA-quality presentation and robust data management!
