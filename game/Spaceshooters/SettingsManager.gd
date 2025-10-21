extends Node

# Settings data
var settings = {
	"fps_limit": 0,  # 0 = unlimited, 60, 120, 144
	"vsync_enabled": true,
	"music_volume": 0.8,  # 0.0 to 1.0
	"sfx_volume": 0.8,
	"graphics_preset": "high",  # low, medium, high, ultra
	"fullscreen": false
}

func _ready():
	load_settings()
	apply_settings()

func apply_settings():
	# Apply FPS limit
	if settings["fps_limit"] == 0:
		Engine.max_fps = 0  # Unlimited
	else:
		Engine.max_fps = settings["fps_limit"]
	
	# Apply VSync
	if settings["vsync_enabled"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# Apply graphics preset
	apply_graphics_preset(settings["graphics_preset"])
	
	# Apply audio settings
	update_audio_volumes()
	
	# Apply fullscreen
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func apply_graphics_preset(preset: String):
	match preset:
		"low":
			# Reduce particle counts
			set_particle_quality(0.5)
			# Disable some effects
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 0)
		"medium":
			set_particle_quality(0.75)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 0)
		"high":
			set_particle_quality(1.0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 2)
		"ultra":
			set_particle_quality(1.5)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 4)

func set_particle_quality(multiplier: float):
	# This will be used by particle systems to adjust their amount
	settings["particle_multiplier"] = multiplier

func update_audio_volumes():
	# Set music volume
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(settings["music_volume"]))
		AudioServer.set_bus_mute(music_bus, settings["music_volume"] == 0)
	
	# Set SFX volume
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(settings["sfx_volume"]))
		AudioServer.set_bus_mute(sfx_bus, settings["sfx_volume"] == 0)

func set_fps_limit(limit: int):
	settings["fps_limit"] = limit
	if limit == 0:
		Engine.max_fps = 0
	else:
		Engine.max_fps = limit
	save_settings()

func set_vsync(enabled: bool):
	settings["vsync_enabled"] = enabled
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	save_settings()

func set_music_volume(volume: float):
	settings["music_volume"] = clamp(volume, 0.0, 1.0)
	update_audio_volumes()
	save_settings()

func set_sfx_volume(volume: float):
	settings["sfx_volume"] = clamp(volume, 0.0, 1.0)
	update_audio_volumes()
	save_settings()

func set_graphics_preset(preset: String):
	settings["graphics_preset"] = preset
	apply_graphics_preset(preset)
	save_settings()

func set_fullscreen(enabled: bool):
	settings["fullscreen"] = enabled
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

func save_settings():
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	if file:
		file.store_var(settings)
		file.close()

func load_settings():
	if FileAccess.file_exists("user://settings.save"):
		var file = FileAccess.open("user://settings.save", FileAccess.READ)
		if file:
			var loaded = file.get_var()
			file.close()
			# Merge loaded settings with defaults
			for key in loaded.keys():
				settings[key] = loaded[key]
