extends Sprite

class_name Enemy_Combat

onready var GM := $"/root/Game_Manager"

var data := Model.Enemy_Data.new()
var stats : Model.Stats_Data
var calc_stats : Model.Calc_Stats_Data

var idle_sprite : Texture
var attack_sprite : Texture
var hit_sprite : Texture
var miss_sprite : Texture
var icon_sprite : Texture

var duration := 0.0
var frames := 0

var elapsed_frame_time := 0.0

func _process(delta: float) -> void:
	if frames > 1:
		if elapsed_frame_time >= duration/frames:
			if self.frame == (frames - 1):
				self.frame = 0;
			else:
				self.frame += 1;
			elapsed_frame_time = 0.0
		
		elapsed_frame_time += delta

func prepare_for_combat(enemy_data : Model.Enemy_Data) -> void:
	data = enemy_data
	duplicate_data(data)
	
	idle_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/enemies/" + data.name + "/idle.png")
	attack_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/enemies/" + data.name + "/attack.png")
	hit_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/enemies/" + data.name + "/hit.png")
	miss_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/enemies/" + data.name + "/miss.png")
	icon_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/enemies/" + data.name + "/icon.png")
	
	self.texture = idle_sprite
	self.scale *= data.scale
	
	if data.animation_data != null:
		_configure_animation(data.animation_data)

func _configure_animation(animation_info) -> void:
	self.vframes = animation_info.vframes
	self.hframes = animation_info.hframes
	self.frames = animation_info.total_frames
	self.duration = animation_info.duration

func duplicate_data(data) -> void:
	stats = Model.Stats_Data.new()
	stats.duplicate(data.stats)
	
	calc_stats = Model.Calc_Stats_Data.new()
	calc_stats.duplicate(data.calc_stats)