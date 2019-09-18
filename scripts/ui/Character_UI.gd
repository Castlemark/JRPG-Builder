extends Button

class_name Character_UI

signal character_selected(character_data)

onready var GM := $"/root/Game_Manager"

onready var name_label : Label = $HBoxContainer/VBoxContainer/Name as Label
onready var level_label : Label = $HBoxContainer/VBoxContainer/Level as Label
onready var icon_rect : TextureRect = $HBoxContainer/Icon as TextureRect 

const _LEVEL = "Level "
const _MAX_LEVEL = 30

var data : Dictionary = {}
var current_stats : Dictionary = {}

func initialize(character : Dictionary) -> void:
	data = character
	
	current_stats = _calculate_current_stats(data.min_stats, data.max_stats, data.start_level)
	
	self.name = data.name
	name_label.text = data.name
	level_label.text = _LEVEL + String(data.start_level)
	
	var img : Texture = Utils.load_img("res://campaigns/" + GM.campaign.name + "/characters/party/" + character.name + "/icon.png")
	if img != null:
		icon_rect.texture = img
	
	self.connect("focus_entered", self, "_on_focus")

func _calculate_current_stats(min_stats : Dictionary, max_stats : Dictionary, current_level : int) -> Dictionary:
	var stats = {}
	
	stats["strength"] = min_stats.strength + (max_stats.strength - min_stats.strength)/_MAX_LEVEL
	stats["dexterity"] = min_stats.dexterity + (max_stats.dexterity - min_stats.dexterity)/_MAX_LEVEL
	stats["constitution"] = min_stats.constitution + (max_stats.constitution - min_stats.constitution)/_MAX_LEVEL
	stats["memory"] = min_stats.memory + (max_stats.memory - min_stats.memory)/_MAX_LEVEL
	stats["critic"] = min_stats.critic + (max_stats.critic - min_stats.critic)/_MAX_LEVEL
	stats["defence"] = min_stats.defence + (max_stats.defence - min_stats.defence)/_MAX_LEVEL
	stats["alt_defence"] = min_stats.alt_defence + (max_stats.alt_defence - min_stats.alt_defence)/_MAX_LEVEL
	stats["speed"] = min_stats.speed + (max_stats.speed - min_stats.speed)/_MAX_LEVEL
	
	stats["hp"] = (min_stats.constitution + 1/4 * min_stats.strength + 1/3 * min_stats.defence + ((max_stats.constitution - min_stats.constitution)/_MAX_LEVEL + 1/4 * (max_stats.strength - min_stats.strength)/_MAX_LEVEL  + 1/3 * min_stats.defence + (max_stats.defence - min_stats.defence)/_MAX_LEVEL)) * 10
	stats["shield"] = (1/4 * min_stats.constitution + min_stats.alt_defence + 1/3 * min_stats.defence + ( 1/4 * (max_stats.constitution - min_stats.constitution)/_MAX_LEVEL + (max_stats.alt_defence - min_stats.alt_defence)/_MAX_LEVEL + 1/3 * min_stats.defence + (max_stats.defence - min_stats.defence)/_MAX_LEVEL)) * 10
	stats["strain"] = (1/2 * min_stats.constitution + min_stats.alt_defence + 1/4 * min_stats.defence + ( 1/2 * (max_stats.constitution - min_stats.constitution)/_MAX_LEVEL + (max_stats.alt_defence - min_stats.alt_defence)/_MAX_LEVEL + 1/3 * min_stats.defence + (max_stats.defence - min_stats.defence)/_MAX_LEVEL)) * 10
	
	return stats

func _on_focus() -> void:
	emit_signal("character_selected", self.data)