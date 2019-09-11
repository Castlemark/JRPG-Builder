extends Button

class_name Character_UI

onready var GM := $"/root/Game_Manager"

onready var name_label : Label = $HBoxContainer/VBoxContainer/Name as Label
onready var level_label : Label = $HBoxContainer/VBoxContainer/Level as Label
onready var icon_rect : TextureRect = $HBoxContainer/Icon as TextureRect 

const _LEVEL = "Level "

var data : Dictionary = {}

func initialize(character : Dictionary) -> void:
	data = character
	
	self.name = data.name
	name_label.text = data.name
	level_label.text = _LEVEL + String(data.start_level)
	
	var img : Texture = Utils.load_img("res://campaigns/" + GM.campaign.name + "/characters/party/" + character.name + "/icon.png")
	if img != null:
		icon_rect.texture = img
