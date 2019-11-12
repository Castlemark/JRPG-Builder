extends Sprite

class_name Character_Combat

onready var GM := $"/root/Game_Manager"

var character := Model.Character_Data.new()

var idle_sprite : Texture
var attack_sprite : Texture
var hit_sprite : Texture
var miss_sprite : Texture

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if frames > 1:
		if elapsed_frame_time >= duration/frames:
			if self.frame == (frames - 1):
				self.frame = 0;
			else:
				self.frame += 1;
			elapsed_frame_time = 0.0
		
		elapsed_frame_time += delta

func prepare_for_combat() -> void:
	match self.name:
		"First":
			character = GM.campaign_data.party.first_character
		"Second":
			character = GM.campaign_data.party.second_character
		"Third":
			character = GM.campaign_data.party.third_character
		_:
			print("Something went wrong, character combat is not first, second or third")
			return
	
	idle_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + character.name + "/idle.png")
	attack_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + character.name + "/attack.png")
	hit_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + character.name + "/hit.png")
	miss_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + character.name + "/miss.png")
	
	self.texture = idle_sprite
	self.scale *= character.scale
	
	if character.animation_data != null:
		_configure_animation(character.animation_data)

func _configure_animation(animation_info) -> void:
	self.vframes = animation_info.vframes
	self.hframes = animation_info.hframes
	self.frames = animation_info.total_frames
	self.duration = animation_info.duration