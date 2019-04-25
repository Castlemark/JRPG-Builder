extends Position3D

class_name Player_Avatar

onready var tween : Tween
onready var skin : Sprite3D

var current_node : Navigation_Node

func initialize(nav_node : Navigation_Node, avatar_img : Texture) -> void:
	tween = $Tween as Tween
	skin = $Skin as Sprite3D
	
	translation = nav_node.translation + Vector3(0, 0, 0.1)
	current_node = nav_node
	
	if avatar_img != null:
		skin.texture = avatar_img

func move_to_pos(destination_node : Position3D ) -> void:
	var target := destination_node.translation + Vector3(0, 0, 0.1)
	var origin := translation
	
	var duration : float = (destination_node.translation - translation).length() / 10.0
	
	tween.interpolate_property(self, "translation", origin, target, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween,"tween_completed")
	current_node = destination_node

func is_moving() -> bool:
	return tween.is_active()

func execute_events() -> void:
	print("implementation pending")