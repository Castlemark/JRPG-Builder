extends Control

class_name Menu_Manager

var item_res : Resource = preload("res://scenes/ui/inventory/Item.tscn")

onready var GM := $"/root/Game_Manager"
onready var inventory_container : GridContainer = $Game_Menu/Inventory/Scroll/Grid as GridContainer
onready var button_group : ButtonGroup = ($"Game_Menu/Inventory/Filter bar/All" as CheckBox).group 

func _ready():
	self.visible = false

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_inventory"):
		self.visible = not self.visible
	
	pass

func initialize(item_list : Array) -> void:
	# TODO check items are valid
	for item in item_list:
		var item_data : Dictionary = Utils.load_json("res://campaigns/" + GM.campaign.name + "/items/" + item + "/item.json")
		if not _validate_item(item_data, item):
			continue
		
		item_data["name"] = item
		
		var item_node : Item = item_res.instance()
		inventory_container.add_child(item_node, true)
		item_node.initialize(item_data)

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

func _validate_item(item_data : Dictionary, item : String) -> bool:
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
