extends Button

class_name Encyclopedia_Enemy

signal enemy_ui_pressed(enemy_data, abilities_data, animated, sprites)

onready var GM := $"/root/Game_Manager"
onready var enemy_icon : TextureRect = $VBoxContainer/Icon as TextureRect
onready var label : Label = $VBoxContainer/Label as Label

var idle_sprite : Texture
var attack_sprite : Texture
var hit_sprite : Texture
var miss_sprite : Texture

var data : Dictionary = {}
var abilities_data : Array = []
var is_animated : bool = false

func initialize(enemy_data : Dictionary, abilities_data : Array) -> void:
	data = enemy_data
	self.abilities_data = abilities_data
	
	label.text = data.name
	var icon_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign.name + "/characters/enemies/" + data.name + "/icon.png")
	if icon_sprite != null:
		enemy_icon.texture = icon_sprite
	
	idle_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign.name + "/characters/enemies/" + data.name + "/idle.png")
	attack_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign.name + "/characters/enemies/" + data.name + "/attack.png")
	hit_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign.name + "/characters/enemies/" + data.name + "/hit.png")
	miss_sprite = Utils.load_img_GUI("res://campaigns/" + GM.campaign.name + "/characters/enemies/" + data.name + "/miss.png")
	
	if Generic_Validators.optional_info_field_exists(data, "animation_data", Data.Validation.animation_data, "detail is marked as animated, but it's missing some of the requeried animation_data fields, " + Data.Validation.check_docu, "filepath"):
		is_animated = true
	


func _on_Enemy_toggled(button_pressed: bool) -> void:
	if button_pressed:
		emit_signal("enemy_ui_pressed", data, abilities_data, is_animated, [idle_sprite, attack_sprite, hit_sprite, miss_sprite])
