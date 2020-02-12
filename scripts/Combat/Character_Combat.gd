extends Sprite

class_name Character_Combat

const base_scale := Vector2(1, 1)

signal special_animation_finished()

onready var GM := $"/root/Game_Manager"

var data := Model.Character_Data.new()

var idle_sprite : Texture
var attack_sprite : Texture
var hit_sprite : Texture
var miss_sprite : Texture
var icon_sprite : Texture

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

func _ready() -> void:
	self.texture = idle_sprite

func _process(delta: float) -> void:
	if frames > 1:
		if elapsed_frame_time >= duration/frames:
			if self.frame == (frames - 1):
				self.frame = 0;
				if self.texture != idle_sprite:
					self.texture = idle_sprite
# warning-ignore:integer_division
					self.offset = Vector2(0, -idle_sprite.get_height() / vframes)
					emit_signal("special_animation_finished")
			else:
				self.frame += 1;
			elapsed_frame_time = 0.0
	else:
		if elapsed_frame_time >= 1.0:
			elapsed_frame_time = 0.0
			if self.texture != idle_sprite:
				self.texture = idle_sprite
# warning-ignore:integer_division
				self.offset = Vector2(0, -idle_sprite.get_height() / vframes)
				emit_signal("special_animation_finished")

	elapsed_frame_time += delta

func prepare_for_combat(character_data) -> void:
	data = character_data

	idle_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + data.name + "/idle.png")
	attack_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + data.name + "/attack.png")
	hit_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + data.name + "/hit.png")
	miss_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + data.name + "/miss.png")
	icon_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + data.name + "/icon.png")

	if data.animation_data != null:
		_configure_animation(data.animation_data)

	self.texture = idle_sprite
	self.scale = base_scale * data.scale
# warning-ignore:integer_division
	self.offset = Vector2(0,-idle_sprite.get_height() / vframes)

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
			self.texture = attack_sprite
# warning-ignore:integer_division
			self.offset = Vector2(0, -attack_sprite.get_height() / vframes)
		"hit":
			elapsed_frame_time = 0.0
			self.frame = 0
			self.texture = hit_sprite
# warning-ignore:integer_division
			self.offset = Vector2(0, -hit_sprite.get_height() / vframes)
		"miss":
			elapsed_frame_time = 0.0
			self.frame = 0
			self.texture = miss_sprite
# warning-ignore:integer_division
			self.offset = Vector2(0, -miss_sprite.get_height() / vframes)
		_:
			print("Animation " + animation + " is not valid")
