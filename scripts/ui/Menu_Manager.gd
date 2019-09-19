extends Control

class_name Menu_Manager

var item_res : Resource = preload("res://scenes/ui/inventory/Item.tscn")
var character_res : Resource = preload("res://scenes/ui/party/Character_UI.tscn")
var character_ability_res : Resource = preload("res://scenes/ui/party/Character_Ability.tscn")

onready var GM := $"/root/Game_Manager"
onready var inventory_container : GridContainer = $Game_Menu/Inventory/Scroll/Grid as GridContainer
onready var button_group_inventory : ButtonGroup = ($"Game_Menu/Inventory/Filter bar/All" as CheckBox).group
onready var character_container : HBoxContainer = $Game_Menu/Party/Party/BG/Scroll/Char_Container as HBoxContainer
onready var character_ability_container : GridContainer = $Game_Menu/Party/Data/HBoxContainer/Abilities/Scroll/Container as GridContainer
onready var character_ability_description : VBoxContainer = $Game_Menu/Party/Data/HBoxContainer/Preview/VBoxContainer as VBoxContainer

func _ready():
	self.visible = false

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_inventory"):
		self.visible = not self.visible
	
	pass

func initialize_inventory(item_list : Array) -> void:
	# TODO check items are valid
	for item in item_list:
		var item_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/items/" + item + "/item.json")
		if not _validate_item(item_data, item):
			continue
		
		item_data["name"] = item
		
		var item_node : Item = item_res.instance()
		inventory_container.add_child(item_node, true)
		item_node.initialize(item_data)

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
		
		character_data["name"] = character
		
		var character_node : Character_UI = character_res.instance()
		character_container.add_child(character_node, true)
		character_node.initialize(character_data, abilities_data)
		character_node.connect("character_selected", self, "_on_player_select")
	pass

func _on_ability_pressed(data : Dictionary, preview_icon : Texture) -> void:
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Icon as TextureRect).texture = preview_icon
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Name as Label).text = String(data.name).replace("_", " ")
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Description as Label).text = data.description
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Level as Label).text = "Level: " + String(data.min_level)
	
	var targets : String = "Targets "
	match (data.target_amount as int):
		1:
			targets += "1 "
		2:
			targets += "2 "
		3:
			targets += "all "
	targets += data.side
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Targets as Label).text = targets
	
	var damage : String = "Damage: " + String(data.damage) + " "
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
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Damage as Label).text = damage
	
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
	effect += "\n    Applies " + String(data.effect.amount) + " "
	if (data.effect.duration as int) > 0:
		var turns := " turn"
		if data.effect.duration != 1:
			turns += "s"
		effect += "for " + String(data.effect.duration) + turns
	if data.effect.type == "none":
		effect = ""
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Effect as Label).text = effect

func _reset_ability_preview():
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Icon as TextureRect).texture = null
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Name as Label).text = ""
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Description as Label).text = ""
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Level as Label).text = ""
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Targets as Label).text = ""
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Damage as Label).text = ""
	($Game_Menu/Party/Data/HBoxContainer/Preview/Scroll/VBoxContainer/Effect as Label).text = ""

func _on_filter_pressed() -> void:
	match button_group_inventory.get_pressed_button().name:
		"All":
			_set_items_visibility(inventory_container.get_children(), true)
		"Equipment":
			_set_items_visibility(get_tree().get_nodes_in_group("equipment"), true)
			_set_items_visibility(get_tree().get_nodes_in_group("consumable"), false)
			_set_items_visibility(get_tree().get_nodes_in_group("quest_object"), false)
		"Consumables":
			_set_items_visibility(get_tree().get_nodes_in_group("equipment"), false)
			_set_items_visibility(get_tree().get_nodes_in_group("consumable"), true)
			_set_items_visibility(get_tree().get_nodes_in_group("quest_object"), false)
		"Quest_Items":
			_set_items_visibility(get_tree().get_nodes_in_group("equipment"), false)
			_set_items_visibility(get_tree().get_nodes_in_group("consumable"), false)
			_set_items_visibility(get_tree().get_nodes_in_group("quest_object"), true)

func _on_player_select(data : Dictionary, abilities : Array) -> void:
	
	($Game_Menu/Party/Data/Stats/HBoxContainer/Hard/Strength as Label).text = "Strength: " + String(round(data.strength))
	($Game_Menu/Party/Data/Stats/HBoxContainer/Hard/Dexterity as Label).text = "Dexterity: " + String(round(data.dexterity))
	($Game_Menu/Party/Data/Stats/HBoxContainer/Hard/Constitution as Label).text = "Constitution: " + String(round(data.constitution))
	($Game_Menu/Party/Data/Stats/HBoxContainer/Hard/Memory as Label).text = "Memory: " + String(round(data.memory))
	($Game_Menu/Party/Data/Stats/HBoxContainer/Hard/Critic as Label).text = "Critic: " + String(round(data.critic * 100)) + "%"
	($Game_Menu/Party/Data/Stats/HBoxContainer/Hard/Defence as Label).text = "Defence: " + String(round(data.defence))
	($"Game_Menu/Party/Data/Stats/HBoxContainer/Hard/Alt Defence" as Label).text = "Alt. Defence: " + String(round(data.alt_defence))
	($Game_Menu/Party/Data/Stats/HBoxContainer/Hard/Speed as Label).text = "Speed: " + String(round(data.speed))
	
	($Game_Menu/Party/Data/Stats/HBoxContainer/Soft/HP as Label). text = "HP: " + String(round(data.hp))
	($Game_Menu/Party/Data/Stats/HBoxContainer/Soft/Shield as Label).text = "Shield: " + String(round(data.shield))
	($Game_Menu/Party/Data/Stats/HBoxContainer/Soft/Strain as Label).text = "Strain: " + String(round(data.strain))
	($Game_Menu/Party/Data/Stats/HBoxContainer/Soft/Evasion as Label).text = "Evasion: " + String(round(data.evasion))
	
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
	elif difference < 0:
		for i in range(abs(difference)):
			var node_to_delete = character_ability_container.get_child(0)
			character_ability_container.remove_child(node_to_delete)
			node_to_delete.queue_free()
	
	for i in range(abilities_data.size()):
		var ability_node : Character_Ability = character_ability_container.get_child(i) as Character_Ability
		ability_node.initialize(abilities_data[i])

func _set_items_visibility(items: Array, visible : bool) -> void:
	for item in items:
		item.visible = visible

func _validate_item(item_data, item : String) -> bool:
	if item_data == null:
		return false
	if not Validators.minimal_info_fields_exist(item_data, ["type", "data"], "item is missing required fields", "", item):
		return false
	if not Validators.type_is_valid(item_data.type, Validators.item_types, item_data.data):
		return false
	
	var valid := true
	match item_data.type:
		"consumable":
			valid = Validators.minimal_info_fields_exist(item_data.data.effect, ["type", "value", "delay", "duration"], "item consumable is missing fields in it's \"effect\" field", "", item)
		"equipment":
			valid = Validators.minimal_info_fields_exist(item_data.data.stats, Validators.stats, "item equipment is missing fields in it's \"stats\" field", "", item)
	
	return valid

func _validate_character(character_data, character : String) -> bool:
	if character_data == null:
		return false
	if not Validators.minimal_info_fields_exist(character_data, ["start_level", "min_stats", "max_stats", "abilities"], "character is missing required fields", "", character):
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
