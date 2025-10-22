extends Node

# Theme Manager System
# Handles multiple UI themes for the game

signal theme_changed(theme_name: String)

# Available themes
enum ThemeType {
	SPACE_BLUE,
	DARK_RED,
	CYBER_GREEN,
	PURPLE_NEON,
	CLASSIC_WHITE
}

var current_theme: ThemeType = ThemeType.SPACE_BLUE
var custom_theme: Theme

# Theme configurations
var themes = {
	ThemeType.SPACE_BLUE: {
		"name": "Space Blue",
		"primary": Color("#00BFFF"),  # Deep Sky Blue
		"secondary": Color("#1E90FF"),  # Dodger Blue
		"accent": Color("#FF4500"),  # Orange Red
		"background": Color("#0A0A2E"),  # Dark Blue
		"text": Color("#FFFFFF"),  # White
		"text_hover": Color("#00FFFF"),  # Cyan
		"button_normal": Color("#1E3A8A"),  # Dark Blue
		"button_hover": Color("#2563EB"),  # Bright Blue
		"button_pressed": Color("#1D4ED8")  # Pressed Blue
	},
	ThemeType.DARK_RED: {
		"name": "Dark Red",
		"primary": Color("#DC143C"),  # Crimson
		"secondary": Color("#8B0000"),  # Dark Red
		"accent": Color("#FF6347"),  # Tomato
		"background": Color("#1A0000"),  # Very Dark Red
		"text": Color("#FFE4E1"),  # Misty Rose
		"text_hover": Color("#FF69B4"),  # Hot Pink
		"button_normal": Color("#660000"),
		"button_hover": Color("#990000"),
		"button_pressed": Color("#CC0000")
	},
	ThemeType.CYBER_GREEN: {
		"name": "Cyber Green",
		"primary": Color("#00FF00"),  # Lime
		"secondary": Color("#00FF7F"),  # Spring Green
		"accent": Color("#ADFF2F"),  # Green Yellow
		"background": Color("#0A1A0A"),  # Dark Green
		"text": Color("#00FF00"),  # Green
		"text_hover": Color("#7FFF00"),  # Chartreuse
		"button_normal": Color("#003300"),
		"button_hover": Color("#006600"),
		"button_pressed": Color("#009900")
	},
	ThemeType.PURPLE_NEON: {
		"name": "Purple Neon",
		"primary": Color("#9400D3"),  # Dark Violet
		"secondary": Color("#8A2BE2"),  # Blue Violet
		"accent": Color("#FF00FF"),  # Magenta
		"background": Color("#1A0A1A"),  # Dark Purple
		"text": Color("#DDA0DD"),  # Plum
		"text_hover": Color("#FF00FF"),  # Magenta
		"button_normal": Color("#4B0082"),  # Indigo
		"button_hover": Color("#6A0DAD"),
		"button_pressed": Color("#8B00FF")
	},
	ThemeType.CLASSIC_WHITE: {
		"name": "Classic White",
		"primary": Color("#F0F0F0"),  # Light Gray
		"secondary": Color("#D3D3D3"),  # Light Gray
		"accent": Color("#4169E1"),  # Royal Blue
		"background": Color("#2F2F2F"),  # Dark Gray
		"text": Color("#FFFFFF"),  # White
		"text_hover": Color("#87CEEB"),  # Sky Blue
		"button_normal": Color("#555555"),
		"button_hover": Color("#777777"),
		"button_pressed": Color("#999999")
	}
}

func _ready():
	# Load saved theme preference
	load_theme_preference()
	apply_theme(current_theme)

# Apply a theme to the game
func apply_theme(theme_type: ThemeType):
	current_theme = theme_type
	
	var theme_config = themes[theme_type]
	
	# Create new theme resource
	custom_theme = Theme.new()
	
	# Configure button style
	var button_style_normal = StyleBoxFlat.new()
	button_style_normal.bg_color = theme_config["button_normal"]
	button_style_normal.corner_radius_top_left = 5
	button_style_normal.corner_radius_top_right = 5
	button_style_normal.corner_radius_bottom_left = 5
	button_style_normal.corner_radius_bottom_right = 5
	
	var button_style_hover = StyleBoxFlat.new()
	button_style_hover.bg_color = theme_config["button_hover"]
	button_style_hover.corner_radius_top_left = 5
	button_style_hover.corner_radius_top_right = 5
	button_style_hover.corner_radius_bottom_left = 5
	button_style_hover.corner_radius_bottom_right = 5
	
	var button_style_pressed = StyleBoxFlat.new()
	button_style_pressed.bg_color = theme_config["button_pressed"]
	button_style_pressed.corner_radius_top_left = 5
	button_style_pressed.corner_radius_top_right = 5
	button_style_pressed.corner_radius_bottom_left = 5
	button_style_pressed.corner_radius_bottom_right = 5
	
	custom_theme.set_stylebox("normal", "Button", button_style_normal)
	custom_theme.set_stylebox("hover", "Button", button_style_hover)
	custom_theme.set_stylebox("pressed", "Button", button_style_pressed)
	
	# Configure label colors
	custom_theme.set_color("font_color", "Label", theme_config["text"])
	custom_theme.set_color("font_hover_color", "Label", theme_config["text_hover"])
	
	# Configure panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = theme_config["background"]
	panel_style.border_color = theme_config["primary"]
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	custom_theme.set_stylebox("panel", "Panel", panel_style)
	
	# Save preference
	save_theme_preference()
	
	# Emit signal
	theme_changed.emit(theme_config["name"])
	
	print("Theme applied: ", theme_config["name"])

# Get current theme
func get_current_theme() -> Theme:
	return custom_theme

# Get theme configuration
func get_theme_config(theme_type: ThemeType) -> Dictionary:
	return themes[theme_type]

# Change theme by name
func set_theme_by_name(theme_name: String):
	for theme_type in themes:
		if themes[theme_type]["name"] == theme_name:
			apply_theme(theme_type)
			return

# Get all available theme names
func get_theme_names() -> Array:
	var names = []
	for theme_type in themes:
		names.append(themes[theme_type]["name"])
	return names

# Save theme preference
func save_theme_preference():
	var config_path = "user://theme_preference.cfg"
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	
	if file:
		file.store_line(str(current_theme))
		file.close()

# Load theme preference
func load_theme_preference():
	var config_path = "user://theme_preference.cfg"
	
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		if file:
			var saved_theme = file.get_line().to_int()
			file.close()
			
			if saved_theme in ThemeType.values():
				current_theme = saved_theme
				print("Loaded saved theme: ", themes[current_theme]["name"])

# Apply theme to a Control node
func apply_theme_to_node(node: Control):
	if custom_theme:
		node.theme = custom_theme
