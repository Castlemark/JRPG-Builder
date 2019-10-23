extends Tabs

class_name Menu_Party

var character_res : Resource = preload("res://scenes/ui/party/Character_UI.tscn")
var character_ability_res : Resource = preload("res://scenes/ui/party/Character_Ability.tscn")

var character_button_group := ButtonGroup.new()
var ability_button_group := ButtonGroup.new()

onready var GM := $"/root/Game_Manager"
onready var character_container : HBoxContainer = $Party/BG/Scroll/Char_Container as HBoxContainer
onready var character_ability_container : GridContainer = $Data/HBoxContainer/Abilities/Scroll/Container as GridContainer

func _ready():
	pass

func initialize_party(character_list : Array) -> void:
	# TODO check for duplicates (characters and abilities)
	if character_list.size() > 3:
		print("A party can't have more than 3 characters at a time, please modify the \"party\" field int your \"campaign.json\" file accordingly")
		return
	
	for character in character_list:
		var character_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/characters/party/" + character + "/character.json")
		if not _validate_character(character_data, character):
			continue
		
		var abilities_data := []
		var abilities_valid := true
		for ability in character_data.abilities:
			var ability_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/abilities/" + ability + "/ability.json")
			if ability_data != null:
				ability_data["name"] = ability
				abilities_data.append(ability_data)
			
			if abilities_valid:
				abilities_valid = _validate_ability(ability_data, ability)
		
		if not abilities_valid:
			print(character + " character is valid, but at least one of its abilities is invalid or may not exist, please check the messages above to see what abilities")
			continue
		
		var equipments_data := {}
		var equpment_valid := true
		for slot in character_data.equipment.keys():
			var equipment_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/items/" + character_data.equipment.get(slot) + "/item.json")
			if equipment_data != null:
				equipment_data["name"] = slot
				equipments_data[slot] = equipment_data
			
			if equpment_valid:
				equpment_valid = _validate_equipment(equipment_data, character_data.equipment.get(slot), slot)
		
		if not equpment_valid:
			print(character + "character is valid, but at least one of its equipments is invalid or may not exist, please check the messages above to see what equipments")
			continue
		
		character_data["name"] = character
		
		var character_node : Character_UI = character_res.instance()
		character_container.add_child(character_node, true)
		character_node.initialize(character_data, abilities_data, equipments_data)
		character_node.connect("character_selected", self, "_on_player_select")
		character_node.group = character_button_group
	pass

func _validate_character(character_data, character : String) -> bool:
	if character_data == null:
		return false
	if not Validators.minimal_info_fields_exist(character_data, ["start_level", "min_stats", "max_stats", "abilities", "equipment"], "character is missing required fields", "", character):
		return false
	if not Validators.minimal_info_fields_exist(character_data.equipment, ["legs", "torso", "accessory_1", "accessory_2", "accessory_3", "weapon"], "character is missing required fields", "", character):
		return false
	if not Validators.minimal_info_fields_exist(character_data.min_stats, Validators.stats, "character is missing required fields in \"min_stats\" field", "", character):
		return false
	if not Validators.minimal_info_fields_exist(character_data.max_stats, Validators.stats, "character is missing required fields in \"max_stats\" field", "", character):
		return false
	return true

func _validate_ability(ability_data, ability : String) -> bool:
	if ability_data == null:
		return false
	if not Validators.minimal_info_fields_exist(ability_data, [ "min_level", "target_amount", "side", "cost", "delay", "damage", "effect", "hits", "description"], "ability is missing required fields", "", ability):
		return false
	if not Validators.minimal_info_fields_exist(ability_data.effect, ["type", "receiver", "amount", "duration"], "ability is missing required fields in \"effect\" field", "", ability):
		return false
	if not Validators.type_is_valid(ability_data.effect.type, Validators.effect_types, {}):
		return false
	if not Validators.type_is_valid(ability_data.effect.receiver, Validators.receiver_types, {}):
		return false
	return true

func _validate_equipment(equipment_data, equipment : String, expected_slot : String) -> bool:
	if equipment_data == null:
		return false
	if not Validators.minimal_info_fields_exist(equipment_data, ["type", "data"], "item is missing required fields", "", equipment):
		return false
	if not Validators.type_is_valid(equipment_data.type, Validators.item_types, equipment_data.data):
		return false
	if not equipment_data.type == "equipment":
		print("the item is valid but is not an equipment piece, please make sure you try to equip an equipment item")
		return false
	if not Validators.type_is_valid(equipment_data.data.slot, Validators.equipment_types, equipment_data):
		return false
	if  not (equipment_data.data.slot as String).is_subsequence_of(expected_slot):
		print(equipment + " equipment was valid, but is in a wrong slot, please make sure the equipment is in it's valid slot")
		return false
	return true

func _on_ability_pressed(data : Dictionary, preview_icon : Texture) -> void:
	var stats : Dictionary = (character_button_group.get_pressed_button() as Character_UI).get_stats()
	
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Icon as TextureRect).texture = preview_icon
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Name as Label).text = String(data.name).replace("_", " ")
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Description as Label).text = data.description
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Level as Label).text = "Level: " + String(data.min_level)
	
	var targets : String = "Targets "
	match (data.target_amount as int):
		1:
			targets += "1 "
		2:
			targets += "2 "
		3:
			targets += "all "
	targets += data.side
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Targets as Label).text = targets
	
	var damage : String = "Damage: " + String(data.damage * stats.damage) + " HP "
	match (data.hits as int):
		-1:
			damage += "until miss "
		_:
			damage += "x " + String(data.hits)
	if data.delay > 0:
		var turns := " turn"
		if data.delay != 1:
			turns += "s"
		damage += "in " + String(data.delay) + turns
	if data.damage == 0:
		damage = " Damage: none"
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Damage as Label).text = damage
	
	var effect : String = "Effect: " + data.effect.type + "\n    "
	match (data.effect.receiver as String):
		"same":
			effect += "Targets same character"
		"complementary":
			var aux_targets : PoolStringArray = targets.split(" ")
			aux_targets.insert(2, "complementary")
			effect += aux_targets.join(" ")
		"opposite":
			var aux_targets : PoolStringArray = targets.split(" ")
			aux_targets.insert(2, "opposite")
			if "enemies" in aux_targets:
				aux_targets.set(3, "allies")
			elif "allies" in aux_targets:
				aux_targets.set(3, "enemies")
			effect += aux_targets.join(" ")
	effect += "\n    Applies " + String(data.effect.amount * stats.damage) + " "
	if (data.effect.duration as int) > 0:
		var turns := " turn"
		if data.effect.duration != 1:
			turns += "s"
		effect += "for " + String(data.effect.duration) + turns
	if data.effect.type == "none":
		effect = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Effect as Label).text = effect

func _reset_ability_preview():
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Icon as TextureRect).texture = null
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Name as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Description as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Level as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Targets as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Damage as Label).text = ""
	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Effect as Label).text = ""

func _on_player_select(data : Dictionary, abilities : Array) -> void:
	
	($Data/Stats/HBoxContainer/Hard/Strength as Label).text = "Strength: " + String(round(data.strength))
	($Data/Stats/HBoxContainer/Hard/Dexterity as Label).text = "Dexterity: " + String(round(data.dexterity))
	($Data/Stats/HBoxContainer/Hard/Constitution as Label).text = "Constitution: " + String(round(data.constitution))
	($Data/Stats/HBoxContainer/Hard/Critic as Label).text = "Critic: " + String(round(data.critic * 100)) + "%"
	($Data/Stats/HBoxContainer/Hard/Defence as Label).text = "Defence: " + String(round(data.defence))
	($"Data/Stats/HBoxContainer/Hard/Alt Defence" as Label).text = "Alt. Defence: " + String(round(data.alt_defence))
	($Data/Stats/HBoxContainer/Hard/Speed as Label).text = "Speed: " + String(round(data.speed))
	
	($Data/Stats/HBoxContainer/Soft/HP as Label). text = "HP: " + String(round(data.hp))
	($Data/Stats/HBoxContainer/Soft/Shield as Label).text = "Shield: " + String(round(data.shield))
	($Data/Stats/HBoxContainer/Soft/Strain as Label).text = "Strain: " + String(round(data.strain))
	($Data/Stats/HBoxContainer/Soft/Evasion as Label).text = "Evasion: " + String(round(data.evasion)) + "%"
	($Data/Stats/HBoxContainer/Soft/Damage as Label).text = "Base Damage: " + String(round(data.damage))
	
	_update_character_abilites_panel(abilities)
	_reset_ability_preview()

func _update_character_abilites_panel(abilities_data : Array) -> void:
	var difference : int =  abilities_data.size() - (character_ability_container.get_child_count() - 2)
	
	if difference > 0:
		for i in range(abs(difference)):
			var character_ability_node : Button = character_ability_res.instance()
			character_ability_container.add_child(character_ability_node, true)
			character_ability_container.move_child(character_ability_node, 0)
			character_ability_node.connect("ability_pressed", self, "_on_ability_pressed")
			character_ability_node.group = ability_button_group
	elif difference < 0:
		for i in range(abs(difference)):
			var node_to_delete = character_ability_container.get_child(0)
			character_ability_container.remove_child(node_to_delete)
			node_to_delete.queue_free()
	
	for i in range(abilities_data.size()):
		var ability_node : Character_Ability = character_ability_container.get_child(i) as Character_Ability
		ability_node.initialize(abilities_data[i])
		ability_node.pressed = false