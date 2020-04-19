extends Button

class_name Character_UI

signal character_selected(character_data)
signal character_unselected(character_data)

onready var name_label : Label = $HBoxContainer/VBoxContainer/Name as Label
onready var level_label : Label = $HBoxContainer/VBoxContainer/Level as Label
onready var icon_rect : TextureRect = $HBoxContainer/Icon as TextureRect

const _LEVEL = "Level "
const _MAX_LEVEL = 30

var data := Model.Character_Data.new()

func initialize(character) -> void:
	data = character

	self.name = data.name
	name_label.text = data.name
	level_label.text = _LEVEL + String(data.cur_level())

	icon_rect.texture = character.icon_texture

func _on_toggled(pressed_button : bool) -> void:
	if pressed_button:
		emit_signal("character_selected", data)
	else:
		emit_signal("character_unselected", data)
