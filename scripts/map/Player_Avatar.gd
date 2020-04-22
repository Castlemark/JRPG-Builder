extends Position3D

class_name Player_Avatar

onready var tween : Tween
onready var skin : Sprite3D

var current_node : Navigation_Node

func initialize(nav_node : Navigation_Node, avatar_img : Texture, avatar_scale : float) -> void:
	tween = $Tween as Tween
	skin = $Skin as Sprite3D
	
	var position := Vector3(0, 0, 0)
	if nav_node != null:
		position = nav_node.translation
	
	translation = position + Vector3(0, 0.26, 0)
	current_node = nav_node
	
	if avatar_img != null:
		skin.texture = avatar_img
		skin.scale *= avatar_scale

func move_to_pos(destination_node : Navigation_Node ) -> void:
	var target := destination_node.translation + Vector3(0, 0.26, 0)
	var origin := translation
	
	var duration : float = (destination_node.translation - translation).length() / 20.0
	
	tween.interpolate_property(self, "translation", origin, target, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween,"tween_completed")
	current_node = destination_node
	execute_actions()

func is_moving() -> bool:
	return tween.is_active()

func execute_actions() -> void:
	for action in current_node.actions.get_children():
		(action as Generic_Action).execute()
		yield(action, "finished")
