extends CanvasLayer

# Mobile touch controls for browser version

signal move_direction(direction: Vector2)
signal shoot_pressed
signal shoot_released

@onready var joystick = $Joystick
@onready var joystick_bg = $Joystick/Background
@onready var joystick_handle = $Joystick/Handle
@onready var shoot_button = $ShootButton

var joystick_active = false
var joystick_touch_index = -1
var joystick_center = Vector2.ZERO
var max_joystick_distance = 50.0

var is_mobile = false

func _ready():
	# Detect if running on mobile/browser
	is_mobile = OS.has_feature("web") or OS.has_feature("mobile")
	
	if is_mobile:
		show()
		setup_controls()
	else:
		hide()
	
	# Connect shoot button
	shoot_button.button_down.connect(_on_shoot_button_down)
	shoot_button.button_up.connect(_on_shoot_button_up)

func setup_controls():
	# Position joystick (bottom-left)
	joystick.position = Vector2(150, get_viewport().get_visible_rect().size.y - 150)
	
	# Position shoot button (bottom-right)
	shoot_button.position = Vector2(get_viewport().get_visible_rect().size.x - 150, 
									get_viewport().get_visible_rect().size.y - 150)
	
	joystick_center = joystick_bg.position

func _input(event):
	if not is_mobile:
		return
	
	# Handle touch events for joystick
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)

func handle_touch(event: InputEventScreenTouch):
	var touch_pos = event.position
	
	# Check if touch is on joystick area
	var joystick_rect = Rect2(joystick.global_position - Vector2(100, 100), Vector2(200, 200))
	
	if joystick_rect.has_point(touch_pos):
		if event.pressed:
			joystick_active = true
			joystick_touch_index = event.index
			update_joystick(touch_pos)
		elif event.index == joystick_touch_index:
			joystick_active = false
			joystick_touch_index = -1
			reset_joystick()

func handle_drag(event: InputEventScreenDrag):
	if joystick_active and event.index == joystick_touch_index:
		update_joystick(event.position)

func update_joystick(touch_pos: Vector2):
	# Convert touch position to joystick local space
	var local_pos = touch_pos - joystick.global_position
	
	# Clamp to max distance
	if local_pos.length() > max_joystick_distance:
		local_pos = local_pos.normalized() * max_joystick_distance
	
	# Update handle position
	joystick_handle.position = joystick_center + local_pos
	
	# Emit normalized direction
	var direction = local_pos / max_joystick_distance
	move_direction.emit(direction)

func reset_joystick():
	joystick_handle.position = joystick_center
	move_direction.emit(Vector2.ZERO)

func _on_shoot_button_down():
	shoot_pressed.emit()

func _on_shoot_button_up():
	shoot_released.emit()

# Call this when viewport size changes
func _on_viewport_size_changed():
	if is_mobile:
		setup_controls()
