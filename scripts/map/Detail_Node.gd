extends Spatial

class_name Detail_Node

onready var GM := $"/root/Game_Manager"
onready var sprite := $Sprite as Sprite3D

const STATIC : int = 0
const ANIMATED : int = 1

var type := STATIC

func initialize(detail_info : Dictionary) -> void:
	var path : String = "res://campaigns/" + GM.campaign.name + "/maps/" + GM.campaign.cur_map.name + "/detail_art/" + detail_info.filepath + ".png"
	var detail_img := Utils.load_img(path)
	
	if detail_img != null and _is_valid_type(detail_info.type):
		sprite.texture = detail_img
		self.translation = Vector3(detail_info.x, 0 , - detail_info.y)
		
		if type == ANIMATED:
			_configure_animation(detail_info.animation_data)
	

func _is_valid_type(type : int) -> bool:
	return type == STATIC or type == ANIMATED

func _configure_animation(detail_info : Dictionary):
	pass