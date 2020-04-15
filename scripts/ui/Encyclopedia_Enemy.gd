extends Button

class_name Encyclopedia_Enemy

signal enemy_ui_pressed(enemy_data, abilities_data, animated, sprites)

onready var enemy_icon : TextureRect = $VBoxContainer/Icon as TextureRect
onready var label : Label = $VBoxContainer/Label as Label

var idle_sprite : Texture
var attack_sprite : Texture
var hit_sprite : Texture
var miss_sprite : Texture

var data := Model.Enemy_Data.new()

var is_animated : bool = false

func initialize(enemy_data : Model.Enemy_Data) -> void:
	data = enemy_data
	
	label.text = data.name
	enemy_icon.texture = enemy_data.icon_texture
	
	idle_sprite = enemy_data.idle_texture
	attack_sprite = enemy_data.attack_texture
	hit_sprite = enemy_data.hit_texture
	miss_sprite = enemy_data.miss_texture
	
	if data.animation_data != null:
		is_animated = true

func _on_Enemy_toggled(button_pressed: bool) -> void:
	if button_pressed:
		emit_signal("enemy_ui_pressed", data, data.abilities, is_animated, [idle_sprite, attack_sprite, hit_sprite, miss_sprite])
