extends Button

class_name Character_UI

signal character_selected(character_data)

onready var GM := $"/root/Game_Manager"

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
	level_label.text = _LEVEL + String(data.start_level)

	var img : Texture = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/characters/party/" + character.name + "/icon.png")
	if img != null:
		icon_rect.texture = img

	self.connect("toggled", self, "_on_toggled")

func _on_toggled(pressed_button : bool) -> void:
	if pressed_button:
		emit_signal("character_selected", data)
