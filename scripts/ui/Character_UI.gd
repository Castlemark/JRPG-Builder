extends Button

class_name Character_UI

signal character_selected(character_data, abilities_data)

onready var GM := $"/root/Game_Manager"

onready var name_label : Label = $HBoxContainer/VBoxContainer/Name as Label
onready var level_label : Label = $HBoxContainer/VBoxContainer/Level as Label
onready var icon_rect : TextureRect = $HBoxContainer/Icon as TextureRect

const _LEVEL = "Level "
const _MAX_LEVEL = 30

var data : Dictionary = {}
var abilities : Array = []
var current_stats : Dictionary = {}
var current_level : int;

func initialize(character : Dictionary, abilities_data : Array) -> void:
	data = character
	abilities = abilities_data

	current_level = data.start_level
	current_stats = _calculate_current_stats(data.min_stats, data.max_stats, current_level)

	self.name = data.name
	name_label.text = data.name
	level_label.text = _LEVEL + String(data.start_level)

	var img : Texture = Utils.load_img_GUI("res://campaigns/" + GM.campaign.name + "/characters/party/" + character.name + "/icon.png")
	if img != null:
		icon_rect.texture = img

	self.connect("toggled", self, "_on_toggled")

func _calculate_current_stats(min_stats : Dictionary, max_stats : Dictionary, current_level : int) -> Dictionary:
	var stats = {}

	stats["strength"] = min_stats.strength + ((current_level - 1) * float(max_stats.strength - min_stats.strength)/_MAX_LEVEL)
	stats["dexterity"] = min_stats.dexterity + (current_level - 1) * float(max_stats.dexterity - min_stats.dexterity)/_MAX_LEVEL
	stats["constitution"] = min_stats.constitution + (current_level - 1) * float(max_stats.constitution - min_stats.constitution)/_MAX_LEVEL
	stats["critic"] = min_stats.critic + (current_level - 1) * float(max_stats.critic - min_stats.critic)/_MAX_LEVEL
	stats["defence"] = min_stats.defence + (current_level - 1) * float(max_stats.defence - min_stats.defence)/_MAX_LEVEL
	stats["alt_defence"] = min_stats.alt_defence + (current_level - 1) * float(max_stats.alt_defence - min_stats.alt_defence)/_MAX_LEVEL
	stats["speed"] = min_stats.speed + (current_level - 1) * float(max_stats.speed - min_stats.speed)/_MAX_LEVEL

	stats["hp"] = (min_stats.constitution + 1/4.0 * float(min_stats.strength) + 1/3.0 * min_stats.defence \
		+ (current_level - 1) * (float(max_stats.constitution - min_stats.constitution)/_MAX_LEVEL + 1/4.0 * (max_stats.strength - min_stats.strength)/_MAX_LEVEL  + 1/3.0 * (max_stats.defence - min_stats.defence)/_MAX_LEVEL)) * 10
	stats["shield"] = (1/4.0 * min_stats.constitution + float(min_stats.alt_defence) + 1/3.0 * min_stats.defence \
		+ (current_level - 1) * ( 1/4.0 * (max_stats.constitution - min_stats.constitution)/_MAX_LEVEL + float(max_stats.alt_defence - min_stats.alt_defence)/_MAX_LEVEL + 1/3.0 * (max_stats.defence - min_stats.defence)/_MAX_LEVEL)) * 10
	stats["strain"] = (1/2.0 * min_stats.speed + float(min_stats.strength) + 1/3.0 * min_stats.alt_defence \
		+ (current_level - 1) * (1/2.0 * (max_stats.speed - min_stats.speed)/_MAX_LEVEL + float(max_stats.strength - min_stats.strength)/_MAX_LEVEL  + 1/3.0 * (max_stats.alt_defence - min_stats.alt_defence)/_MAX_LEVEL)) * 10
	stats["evasion"] = (float(min_stats.speed) + 1/2.0 * min_stats.critic * 100 + 1/4.0 * min_stats.defence \
		+ (current_level - 1) * (float(max_stats.speed - min_stats.speed)/_MAX_LEVEL + 1/2.0 * ((max_stats.critic - min_stats.critic)/_MAX_LEVEL) * 100  + 1/4.0 * (max_stats.defence - min_stats.defence)/_MAX_LEVEL)) * 10
	stats["damage"] = (1/4.0 * min_stats.strength + 1/4.0 * min_stats.dexterity + 1/8.0 * min_stats.speed \
		+ (current_level - 1) * (1/4.0 * (max_stats.strength - min_stats.strength)/_MAX_LEVEL + 1/4.0 * (max_stats.dexterity - min_stats.dexterity)/_MAX_LEVEL  + 1/8.0 * (max_stats.speed - min_stats.speed)/_MAX_LEVEL)) * 10

	return stats

func get_stats() -> Dictionary:
	return _calculate_current_stats(data.min_stats, data.max_stats, current_level)

func _on_toggled(pressed_button : bool) -> void:
	if pressed_button:
		emit_signal("character_selected", self.current_stats, self.abilities)
