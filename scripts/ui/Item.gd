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

	var img : Texture = item.icon_texture
	if img != null:
		image.texture = img
