extends Spatial

class_name Detail_Node

onready var GM := $"/root/Game_Manager"
onready var sprite := $Sprite as Sprite3D

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

func initialize(detail_info : Dictionary) -> void:
	
	var path : String = "res://campaigns/" + GM.campaign.name + "/maps/" + GM.campaign.cur_map.name + "/detail_art/" + detail_info.filepath + ".png"
	var detail_img := Utils.load_img_3D(path)
	
	if detail_img != null:
		sprite.texture = detail_img
	
	self.translation = Vector3(detail_info.x, 0 , - detail_info.y)
	if detail_info.rotation == 1:
		sprite.transform = Transform(Vector3(4, 0, 0), Vector3(3, 1.732, 0), Vector3(0, 0, 4), Vector3(0, 0, 0))
		self.rotation_degrees = Vector3(0, 90, 0)
	
	if Generic_Validators.optional_info_field_exists(detail_info, "animation_data", Data.Validation.animation_data, "detail is marked as animated, but it's requeried animation_data fields are either missing or incorrect, " + Data.Validation.check_docu, "filepath"):
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
