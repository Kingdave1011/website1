extends Node

# Music playlist
var playlist = [
	"res://sounds/dreams.mp3",
	"res://sounds/adaytoremember.mp3",
	"res://sounds/melancholylull.mp3",
	"res://sounds/softvibes.mp3",
	"res://sounds/sunsetreverie.mp3"
]

var song_names = [
	"Dreams",
	"A Day to Remember",
	"Melancholy Lull",
	"Soft Vibes",
	"Sunset Reverie"
]

var music_player: AudioStreamPlayer
var current_track = 0
var is_playing = false

func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(_on_song_finished)
	
	# Auto-play first track
	play_track(0)

func play_track(index: int):
	if index < 0 or index >= playlist.size():
		return
	
	current_track = index
	var track = load(playlist[index])
	if track:
		music_player.stream = track
		music_player.volume_db = -8
		music_player.play()
		is_playing = true

func _on_song_finished():
	# Auto-play next track in playlist
	next_track()

func next_track():
	current_track = (current_track + 1) % playlist.size()
	play_track(current_track)

func previous_track():
	current_track = (current_track - 1 + playlist.size()) % playlist.size()
	play_track(current_track)

func toggle_pause():
	if is_playing:
		music_player.stream_paused = !music_player.stream_paused

func stop():
	music_player.stop()
	is_playing = false

func get_current_song_name() -> String:
	if current_track < song_names.size():
		return song_names[current_track]
	return ""

func set_volume(volume_db: float):
	music_player.volume_db = volume_db
