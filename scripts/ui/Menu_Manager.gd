extends Control

class_name Menu_Manager

var item_res : Resource = preload("res://scenes/ui/inventory/Item.tscn")
var character_res : Resource = preload("res://scenes/ui/party/Character_UI.tscn")

onready var GM := $"/root/Game_Manager"
onready var inventory_container : GridContainer = $Game_Menu/Inventory/Scroll/Grid as GridContainer
onready var character_container : HBoxContainer = $Game_Menu/Party/Party/BG/Scroll/Char_Container as HBoxContainer
onready var button_group : ButtonGroup = ($"Game_Menu/Inventory/Filter bar/All" as CheckBox).group 

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
		
		var abilities_valid := true
		for ability in character_data.abilities:
			var ability_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/abilities/" + ability + "/ability.json")
			if abilities_valid:
				abilities_valid = _validate_ability(ability_data, ability)
		
		if not abilities_valid:
			print(character + " character is valid, but at least one of its abilities is invalid or may not exist, please check the messages above to see what abilities")
			continue
		
		character_data["name"] = character
		
		var character_node : Character_UI = character_res.instance()
		character_container.add_child(character_node, true)
		character_node.initialize(character_data)
	pass

func _on_pressed() -> void:
	match button_group.get_pressed_button().name:
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
	if not Validators.minimal_info_fields_exist(ability_data, ["target_amount", "side", "cost", "delay", "damage", "effect", "hits", "description"], "ability is missing required fields", "", ability):
		return false
	if not Validators.minimal_info_fields_exist(ability_data.effect, ["type", "receiver", "amount", "duration"], "ability is missing required fields in \"effect\" field", "", ability):
		return false
	if not Validators.type_is_valid(ability_data.effect.type, Validators.effect_types, {}):
		return false
	if not Validators.type_is_valid(ability_data.effect.receiver, Validators.receiver_types, {}):
		return false
	return true
