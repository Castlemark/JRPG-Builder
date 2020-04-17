extends Button

class_name Item

const ENABLED := Color(1, 1, 1, 1)
const DISABLED := Color(1, 1, 1, 0.25)

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

func disable(should_disable : bool) -> void:
	self.disabled = should_disable
	self.focus_mode = FOCUS_NONE if should_disable else FOCUS_ALL
	image.modulate = DISABLED if should_disable else ENABLED
