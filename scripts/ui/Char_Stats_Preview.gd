extends Button

class_name Char_Stats_Preview

const NEUTRAL_COLOR := Color(1, 1, 1)
const POS_COLOR := Color(0.388235, 0.760784, 0.34902)
const NEG_COLOR := Color(1, 0.439216, 0.521569)

onready var character_icon := $Character/Icon as TextureRect

onready var evasion_diff := $Character/Evasion as Label
onready var health_diff := $Character/Health as Label
onready var damage_diff := $Character/Damage as Label
onready var strain_diff := $Character/Strain as Label
onready var critic_diff := $Character/Critic as Label
onready var speed_diff := $Character/Speed as Label

var character_data : Model.Character_Data
var full_stats : Model.Stats_Data

func set_character(character_data : Model.Character_Data):
	self.character_data = character_data
	character_icon.texture = character_data.icon_texture
	full_stats = character_data.full_stats(character_data.equipment)
	
	set_full_stats()

func set_diff_with_item(item_data : Model.Item_Data.Equipment_Item_Data):
	var mod_eq := character_data.equipment.duplicate_eq()
	
	match item_data.slot:
		"legs":
			mod_eq.legs = item_data
		"torso":
			mod_eq.torso = item_data
		"weapon":
			mod_eq.weapon = item_data
		"accessory":
			mod_eq.accessory_1 = item_data
	
	var diff_stats := character_data.calc_diff(mod_eq)
	
	if diff_stats.max_health > 0:
		health_diff.text = "+" + String(diff_stats.max_health)
		health_diff.add_color_override("font_color", POS_COLOR)
	elif diff_stats.max_health < 0:
		health_diff.text = String(diff_stats.max_health)
		health_diff.add_color_override("font_color", NEG_COLOR)
	else:
		health_diff.text = "+" + String(diff_stats.max_health)
		health_diff.add_color_override("font_color", NEUTRAL_COLOR)
	
	if diff_stats.max_damage > 0:
		damage_diff.text = "+" + String(diff_stats.max_damage)
		damage_diff.add_color_override("font_color", POS_COLOR)
	elif diff_stats.max_damage < 0:
		damage_diff.text = String(diff_stats.max_damage)
		damage_diff.add_color_override("font_color", NEG_COLOR)
	else:
		damage_diff.text = "+" + String(diff_stats.max_damage)
		damage_diff.add_color_override("font_color", NEUTRAL_COLOR)
	
	if diff_stats.max_strain > 0:
		strain_diff.text = "+" + String(diff_stats.max_strain)
		strain_diff.add_color_override("font_color", POS_COLOR)
	elif diff_stats.max_strain < 0:
		strain_diff.text = String(diff_stats.max_strain)
		strain_diff.add_color_override("font_color", NEG_COLOR)
	else:
		strain_diff.text = "+" + String(diff_stats.max_strain)
		strain_diff.add_color_override("font_color", NEUTRAL_COLOR)
	
	if diff_stats.max_evasion > 0:
		evasion_diff.text = "+" + String(stepify(diff_stats.max_evasion * 100, 1)) + "%"
		evasion_diff.add_color_override("font_color", POS_COLOR)
	elif diff_stats.max_evasion < 0:
		evasion_diff.text = String(stepify(diff_stats.max_evasion * 100, 1)) + "%"
		evasion_diff.add_color_override("font_color", NEG_COLOR)
	else:
		evasion_diff.text = "+" + String(stepify(diff_stats.max_evasion * 100, 1)) + "%"
		evasion_diff.add_color_override("font_color", NEUTRAL_COLOR)
	
	if diff_stats.critic > 0:
		critic_diff.text = "+" + String(stepify(diff_stats.critic * 100, 1)) + "%"
		critic_diff.add_color_override("font_color", POS_COLOR)
	elif diff_stats.critic < 0:
		critic_diff.text = String(stepify(diff_stats.critic * 100, 1)) + "%"
		critic_diff.add_color_override("font_color", NEG_COLOR)
	else:
		critic_diff.text = "+" + String(stepify(diff_stats.critic * 100, 1)) + "%"
		critic_diff.add_color_override("font_color", NEUTRAL_COLOR)
	
	if diff_stats.speed > 0:
		speed_diff.text = "+" + String(diff_stats.speed)
		speed_diff.add_color_override("font_color", POS_COLOR)
	elif diff_stats.speed < 0:
		speed_diff.text = String(diff_stats.speed)
		speed_diff.add_color_override("font_color", NEG_COLOR)
	else:
		speed_diff.text = "+" + String(diff_stats.speed)
		speed_diff.add_color_override("font_color", NEUTRAL_COLOR)

func set_full_stats():
	evasion_diff.text = String(stepify(full_stats.max_evasion * 100, 1)) + "%"
	evasion_diff.add_color_override("font_color", NEUTRAL_COLOR)
	health_diff.text = String(full_stats.health) + "/" + String(full_stats.max_health)
	health_diff.add_color_override("font_color", NEUTRAL_COLOR)
	damage_diff.text = String(full_stats.max_damage)
	damage_diff.add_color_override("font_color", NEUTRAL_COLOR)
	strain_diff.text = String(full_stats.max_strain)
	strain_diff.add_color_override("font_color", NEUTRAL_COLOR)
	critic_diff.text = String(stepify(full_stats.critic * 100, 1)) + "%"
	critic_diff.add_color_override("font_color", NEUTRAL_COLOR)
	speed_diff.text = String(full_stats.speed)
	speed_diff.add_color_override("font_color", NEUTRAL_COLOR)
