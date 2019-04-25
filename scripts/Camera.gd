extends Camera

class_name Map_Camera

const MOVE_MARGIN : float = 0.1
const SPEED : int = 6

var original_position : Vector3

var height : int
var width : int

var margin_up : int
var margin_down : int
var margin_right : int
var margin_left : int

var direction : Vector3

var should_move : bool

onready var tween : Tween = $Tween as Tween

func _ready() -> void:
	original_position = translation
	
	height = get_viewport().get_visible_rect().size.y
	width = get_viewport().get_visible_rect().size.x
	
	margin_up = int(height * MOVE_MARGIN)
	margin_down = int(height - height * MOVE_MARGIN)
	margin_left = int(height * MOVE_MARGIN)
	margin_right = int(width - height * MOVE_MARGIN)
	
	direction = Vector3(0, 0, 0)
	
	should_move = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		direction = calculate_motion_direction(event.position)
	
	if Input.is_action_just_pressed("reset_camera_map") and has_camera_moved():
		return_to_original_position()


func _process(delta: float) -> void:
	if should_move:
		global_translate(SPEED * delta * direction)
	
func calculate_motion_direction(position : Vector2) -> Vector3:
	var direction := Vector3(0, 0, 0)
	
	if position.y< margin_up:
		direction += Vector3(0, 0, -1)
	elif position.y > margin_down:
		direction += Vector3(0, 0, 1)
	
	if position.x < margin_left:
		direction += Vector3(-1, 0, 0)
	elif position.x > margin_right:
		direction += Vector3(1, 0, 0)
	
	if direction != Vector3(0, 0, 0):
		should_move = true
	
	return direction

func has_camera_moved() -> bool:
	return translation != original_position

func return_to_original_position() -> void:
	tween.interpolate_property(self, "translation", translation, original_position, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()