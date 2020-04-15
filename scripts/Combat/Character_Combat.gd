extends Sprite

class_name Character_Combat

const base_scale := Vector2(1, 1)

signal special_animation_finished()

var data := Model.Character_Data.new()

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

func _ready() -> void:
	self.texture = data.idle_texture

func _process(delta: float) -> void:
	if frames > 1:
		if elapsed_frame_time >= duration/frames:
			if self.frame == (frames - 1):
				self.frame = 0;
				if self.texture != data.idle_texture:
					self.texture = data.idle_texture
# warning-ignore:integer_division
					self.offset = Vector2(0, -data.idle_texture.get_height() / vframes)
					emit_signal("special_animation_finished")
			else:
				self.frame += 1;
			elapsed_frame_time = 0.0
	else:
		if elapsed_frame_time >= 1.0:
			elapsed_frame_time = 0.0
			if self.texture != data.idle_texture:
				self.texture = data.idle_texture
# warning-ignore:integer_division
				self.offset = Vector2(0, -data.idle_texture.get_height() / vframes)
				emit_signal("special_animation_finished")

	elapsed_frame_time += delta

func prepare_for_combat(character_data) -> void:
	data = character_data

	if data.animation_data != null:
		_configure_animation(data.animation_data)

	self.texture = data.idle_texture
	self.scale = base_scale * data.scale
# warning-ignore:integer_division
	self.offset = Vector2(0,-data.idle_texture.get_height() / vframes)

func _configure_animation(animation_info) -> void:
	self.vframes = animation_info.vframes
	self.hframes = animation_info.hframes
	self.frames = animation_info.total_frames
	self.duration = animation_info.duration

func play_animation(animation : String) -> void:
	match animation:
		"attack":
			elapsed_frame_time = 0.0
			self.frame = 0
			self.texture = data.attack_texture
# warning-ignore:integer_division
			self.offset = Vector2(0, -data.attack_texture.get_height() / vframes)
		"hit":
			elapsed_frame_time = 0.0
			self.frame = 0
			self.texture = data.hit_texture
# warning-ignore:integer_division
			self.offset = Vector2(0, -data.hit_texture.get_height() / vframes)
		"miss":
			elapsed_frame_time = 0.0
			self.frame = 0
			self.texture = data.miss_texture
# warning-ignore:integer_division
			self.offset = Vector2(0, -data.miss_texture.get_height() / vframes)
		_:
			print("Animation " + animation + " is not valid")
