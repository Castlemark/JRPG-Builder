extends Panel

class_name Party_Preview

var char_stats_preview_res := preload("res://scenes/ui/inventory/Char_Stats_Preview.tscn")

onready var button_group_char_preview := ButtonGroup.new()

onready var container := $Scroll/Party_Container as HBoxContainer

var cur_character : Model.Character_Data

func _ready():
	if Game_Manager.campaign_data == null:
		return
	for character in Game_Manager.campaign_data.characters.values():
		var char_stats_preview_node := char_stats_preview_res.instance() as Char_Stats_Preview
		char_stats_preview_node.name = character.name
		container.add_child(char_stats_preview_node, true)
		char_stats_preview_node.group = button_group_char_preview
		char_stats_preview_node.set_character(character)
		char_stats_preview_node.connect("pressed", self, "_on_char_preview_pressed")
	container.get_child(1).pressed = true
	_on_char_preview_pressed()

func set_item_preview(item_data):
	var char_previews : Array = container.get_children()
	
	for i in range(1, char_previews.size()):
		if item_data.type == "equipment":
			char_previews[i].set_diff_with_item(item_data)
		else:
			char_previews[i].set_full_stats()

func _on_char_preview_pressed():
	cur_character = button_group_char_preview.get_pressed_button().character_data
