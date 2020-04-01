extends Camera

class_name Map_Camera

const SPEED : int = 6
const MAX_ACC : int = 48

var original_position : Vector3

var height : int
var width : int

var direction : Vector3
var acceleration : float

var should_move : bool
var trigger_move : bool

onready var tween : Tween = $Tween as Tween

func _ready() -> void:
	original_position = translation
	
	height = get_viewport().get_visible_rect().size.y
	width = get_viewport().get_visible_rect().size.x
	
	get_tree().root.connect("size_changed", self, "on_window_resize")
	
	direction = Vector3(0, 0, 0)
	
	should_move = true
	trigger_move = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset_camera_map") and has_camera_moved():
		return_to_original_position()
	
	if Input.is_action_just_pressed("click right mouse"):
		trigger_move = true
	if Input.is_action_just_released("click right mouse"):
		trigger_move = false

func _process(delta: float) -> void:
	if trigger_move and should_move:
		direction = calculate_motion_direction(get_viewport().get_mouse_position())
		acceleration = calculate_acceleration(get_viewport().get_mouse_position())
		
		global_translate((SPEED + acceleration) * delta * direction)
	

func calculate_motion_direction(position : Vector2) -> Vector3:
	var direction2D := position - Vector2(width/2.0, height/2.0)
	
	direction2D = direction2D.normalized()
	
	return Vector3(direction2D.x, 0 , direction2D.y)

func calculate_acceleration(position : Vector2) -> float:
	var  direction2D := position - Vector2(width/2.0, height/2.0)
	
	# We use this formula to get a value of 1 when the user is clicking from the egde of the screen in the veritcal axis, we use 2.1 instead of 2.0 to give a little bit off margin
	var magnitude := 2.1 * direction2D.length()/height
	return MAX_ACC * magnitude

func has_camera_moved() -> bool:
	return translation != original_position

func return_to_original_position() -> void:
	tween.interpolate_property(self, "translation", translation, original_position, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func on_window_resize() -> void:
	height = get_viewport().get_visible_rect().size.y
	width = get_viewport().get_visible_rect().size.x

func on_ui_toggle(ui_active : bool) -> void:
	should_move = not ui_active
