extends Spatial

class_name Detail_Node

onready var GM := $"/root/Game_Manager"
onready var sprite := $Sprite as Sprite3D

const STATIC : int = 0
const ANIMATED : int = 1

var type := STATIC
var duration := 0.0
var frames := 0

func initialize(detail_info : Dictionary) -> void:
	if not _minimal_info_fields_exist(detail_info):
		return
	
	var path : String = "res://campaigns/" + GM.campaign.name + "/maps/" + GM.campaign.cur_map.name + "/detail_art/" + detail_info.filepath + ".png"
	var detail_img := Utils.load_img(path)
	
	if detail_img != null and _is_valid_type(detail_info.type):
		sprite.texture = detail_img
		type = detail_info.type
		self.translation = Vector3(detail_info.x, 0 , - detail_info.y)
		
		if type == ANIMATED:
			if not _optional_info_fields_exist(detail_info):
				return
			
			_configure_animation(detail_info.animation_data)

func _is_valid_type(type : int) -> bool:
	return type == STATIC or type == ANIMATED

func _configure_animation(animation_info : Dictionary):
	sprite.vframes = animation_info.vframes
	sprite.hframes = animation_info.hframes
	duration = animation_info.duration

func _process(delta: float) -> void:
	pass

func _minimal_info_fields_exist(info : Dictionary) -> bool:
	var valid : bool = info.has("x") \
			 and info.has("y") \
			 and info.has("filepath") \
			 and info.has("type")
	
	if not valid:
		if info.has("filepath"):
			print("detail " + info.filepath + " doesn't have the necessary fields to initialize properly, please check the documentation on map details to know the necessary fields")
		else:
			print("detail doesn't have the necessary fields to initialize properly, please check the documentation on map details to know the necessary fields")
	
	return valid

func _optional_info_fields_exist(info : Dictionary) -> bool:
	var parent_valid : bool = info.has("animation_data")
	
	if not parent_valid:
		print("detail " + info.filepath + " is marked as animated but has no animation data")
		return false
	
	var valid : bool = info.animation_data.has("hframes") \
			 and info.animation_data.has("vframes") \
			 and info.animation_data.has("total_frames") \
			 and info.animation_data.has("duration")
	
	if not valid:
		print("detail " + info.filepath + " is marked as animated, but it's missing some of the requeried animation_data fields, please check the documentation to ensure you have all necessary fields")
	
	return valid