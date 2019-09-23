extends Button

class_name Item

onready var GM := $"/root/Game_Manager"

onready var label : Label = $VBoxContainer/Label as Label
onready var image : TextureRect = $VBoxContainer/Image as TextureRect

var data : Dictionary = {}

func initialize(item : Dictionary) -> void:
	data = item.data

	self.add_to_group(item.type)
	label.text = item.name

	var tooltip := String(data)
	tooltip = tooltip.substr(1, tooltip.length() - 1).replace(",", "\n")
	self.hint_tooltip = tooltip

	var img : Texture = Utils.load_img_GUI("res://campaigns/" + GM.campaign.name + "/items/" + item.name + "/item.png")
	if img != null:
		image.texture = img
