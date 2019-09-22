extends Button

class_name Encyclopedia_Enemy

onready var enemy_icon : TextureRect = $VBoxContainer/Icon as TextureRect
onready var label : Label = $VBoxContainer/Label as Label

var data : Dictionary = {}

func initialize(enemy_data : Dictionary) -> void:
	data = enemy_data
