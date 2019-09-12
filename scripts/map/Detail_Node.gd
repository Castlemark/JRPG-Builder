extends Spatial

class_name Detail_Node

onready var GM := $"/root/Game_Manager"
onready var sprite := $Sprite as Sprite3D

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

func initialize(detail_info : Dictionary) -> void:
	
	var path : String = "res://campaigns/" + GM.campaign.name + "/maps/" + GM.campaign.cur_map.name + "/detail_art/" + detail_info.filepath + ".png"
	var detail_img := Utils.load_img(path)
	
	if detail_img != null:
		sprite.texture = detail_img
	
	self.translation = Vector3(detail_info.x, 0 , - detail_info.y)
	
	if Validators.optional_info_field_exists(detail_info, "animation_data", ["hframes", "vframes", "total_frames", "duration"], "detail is marked as animated, but it's missing some of the requeried animation_data fields, " + Validators.check_docu, "filepath"):
		_configure_animation(detail_info.animation_data)

func _process(delta: float) -> void:
	if frames > 1:
		if elapsed_frame_time >= duration/frames:
			if sprite.frame == (frames - 1):
				sprite.frame = 0;
			else:
				sprite.frame += 1;
			elapsed_frame_time = 0.0
		
		elapsed_frame_time += delta

func _configure_animation(animation_info : Dictionary):
	sprite.vframes = animation_info.vframes
	sprite.hframes = animation_info.hframes
	frames = animation_info.total_frames
	duration = animation_info.duration
