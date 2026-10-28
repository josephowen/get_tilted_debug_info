extends Control

@export var rolling_average_window_size: int = 20

@onready var cursor: Sprite2D = %Cursor
@onready var raw_x_velocity_label: Label = %RawXVelocityLabel
@onready var raw_y_velocity_label: Label = %RawYVelocityLabel
@onready var smoothed_x_velocity_label: Label = %SmoothedXVelocityLabel
@onready var smoothed_y_velocity_label: Label = %SmoothedYVelocityLabel
@onready var roll_label: Label = %RollLabel
@onready var pitch_label: Label = %PitchLabel
@onready var max_x_velocity_label: Label = %MaxXVelocityLabel
@onready var max_y_velocity_label: Label = %MaxYVelocityLabel
@onready var top_button_label: Label = %TopButtonLabel
@onready var bottom_button_label: Label = %BottomButtonLabel

var mouse_velocity_x_values: Array[float] = []
var mouse_velocity_y_values: Array[float] = []

var mouse_max_velocity_x = 0
var mouse_max_velocity_y = 0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.use_accumulated_input = false


func _input(event: InputEvent) -> void:
	# Needed to ensure mouse is captured on web build.
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
	if Input.is_action_pressed("top"):
		top_button_label.text = "  yes"
	else:
		top_button_label.text = "   no"
	if Input.is_action_pressed("bottom"):
		bottom_button_label.text = "  yes"
	else:
		bottom_button_label.text = "   no"
	
	var mouse_velocity = Input.get_last_mouse_velocity()
	var scaled_mouse_velocity = mouse_velocity
	# Web builds appear to report double mouse velocity.
	# Tested on Windows in both Chrome and Firefox.
	if OS.has_feature('web'):
		scaled_mouse_velocity = mouse_velocity / 2.0
	var mouse_velocity_x = scaled_mouse_velocity.x
	var mouse_velocity_y = scaled_mouse_velocity.y
	
	cursor.position += mouse_velocity * delta;
	if cursor.position.x > 1920:
		cursor.position.x -= 1920
	elif cursor.position.x < 0:
		cursor.position.x += 1920
	if cursor.position.y > 1080:
		cursor.position.y -= 1080
	elif cursor.position.y < 0:
		cursor.position.y += 1080
	
	mouse_max_velocity_x = max(mouse_max_velocity_x, abs(mouse_velocity_x))
	mouse_max_velocity_y = max(mouse_max_velocity_y, abs(mouse_velocity_y))
	
	# Calculate rolling average of mouse velocity values.
	mouse_velocity_x_values.append(mouse_velocity_x)
	if len(mouse_velocity_x_values) > rolling_average_window_size:
		mouse_velocity_x_values.pop_front()
	mouse_velocity_y_values.append(mouse_velocity_y)
	if len(mouse_velocity_y_values) > rolling_average_window_size:
		mouse_velocity_y_values.pop_front()

	var mouse_velocity_x_values_avg = 0
	if len(mouse_velocity_x_values) > 0:
		var mouse_velocity_x_values_sum = 0
		for value in mouse_velocity_x_values:
			mouse_velocity_x_values_sum += value
		mouse_velocity_x_values_avg = mouse_velocity_x_values_sum / len(mouse_velocity_x_values)
	
	var mouse_velocity_y_values_avg = 0
	if len(mouse_velocity_y_values) > 0:
		var mouse_velocity_y_values_sum = 0
		for value in mouse_velocity_y_values:
			mouse_velocity_y_values_sum += value
		mouse_velocity_y_values_avg = mouse_velocity_y_values_sum / len(mouse_velocity_y_values)
	
	var roll = clamp(remap(mouse_velocity_x_values_avg, -1600, 1600, -90, 90), -90, 90)
	#Invert pitch angle to be more intuitive.
	var pitch = clamp(remap(mouse_velocity_y_values_avg, -1600, 1600, 90, -90), -90, 90)

	raw_x_velocity_label.text = "%10d" % mouse_velocity_x
	raw_y_velocity_label.text = "%10d" % mouse_velocity_y
	smoothed_x_velocity_label.text = "%10d" % mouse_velocity_x_values_avg
	smoothed_y_velocity_label.text = "%10d" % mouse_velocity_y_values_avg
	roll_label.text = "%4d degrees" % roll
	pitch_label.text = "%4d degrees" % pitch
	max_x_velocity_label.text = "%10d" % mouse_max_velocity_x
	max_y_velocity_label.text = "%10d" % mouse_max_velocity_y
