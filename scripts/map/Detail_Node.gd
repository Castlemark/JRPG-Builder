extends Spatial

class_name Detail_Node

onready var GM := $"/root/Game_Manager"
onready var sprite := $Sprite as Sprite3D

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

func initialize(detail_info) -> void:
	
	var detail_img : Texture = detail_info.texture
	
	if detail_img != null:
		sprite.texture = detail_img
	
	self.translation = Vector3(detail_info.x, 0 , - detail_info.y)
	if detail_info.rotation == 1:
		sprite.transform = Transform(Vector3(4, 0, 0), Vector3(3, 1.732, 0), Vector3(0, 0, 4), Vector3(0, 0, 0))
		self.rotation_degrees = Vector3(0, 90, 0)
	
	self.scale *= detail_info.scale
	
	if detail_info.animation_data != null:
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

func _configure_animation(animation_info):
	sprite.vframes = animation_info.vframes
	sprite.hframes = animation_info.hframes
	frames = animation_info.total_frames
	duration = animation_info.duration
