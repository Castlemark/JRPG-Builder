extends Button

class_name Item

onready var GM := $"/root/Game_Manager"

onready var label : Label = $VBoxContainer/Label as Label
onready var image : TextureRect = $VBoxContainer/Image as TextureRect

var data

func initialize(item) -> void:
	data = item

	self.add_to_group(data.type)
	label.text = data.name

	var tooltip := String(data.name)
	self.hint_tooltip = tooltip

	var img : Texture = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data_model.name + "/items/" + data.name + "/item.png")
	if img != null:
		image.texture = img
