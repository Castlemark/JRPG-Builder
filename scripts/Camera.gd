extends Camera

class_name Map_Camera

const SPEED : int = 12
const MAX_ACC : int = 48
const INCREMENT_ACC : float = 0.5

var original_position : Vector3

var height : int
var width : int

var direction : Vector3
var acceleration : float

var trigger_move : bool

onready var tween : Tween = $Tween as Tween

func _ready() -> void:
	original_position = translation
	
	height = get_viewport().get_visible_rect().size.y
	width = get_viewport().get_visible_rect().size.x
	
	get_tree().root.connect("size_changed", self, "on_window_resize")
	
	direction = Vector3(0, 0, 0)
	acceleration = 0.0
	
	trigger_move = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset_camera_map") and has_camera_moved():
		return_to_original_position()
	
	if Input.is_action_just_pressed("click right mouse"):
		trigger_move = true
	if Input.is_action_just_released("click right mouse"):
		trigger_move = false
		acceleration = 0.0


func _process(delta: float) -> void:
	if trigger_move:
		if acceleration < MAX_ACC:
			acceleration += INCREMENT_ACC
		
		direction = calculate_motion_direction(get_viewport().get_mouse_position())
		global_translate((SPEED + acceleration) * delta * direction)
	

func calculate_motion_direction(position : Vector2) -> Vector3:
	var direction2D := position - Vector2(width/2, height/2)
	
	direction2D = direction2D.normalized()
	
	return Vector3(direction2D.x, 0 , direction2D.y)

func has_camera_moved() -> bool:
	return translation != original_position

func return_to_original_position() -> void:
	tween.interpolate_property(self, "translation", translation, original_position, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func on_window_resize():
	height = get_viewport().get_visible_rect().size.y
	width = get_viewport().get_visible_rect().size.x