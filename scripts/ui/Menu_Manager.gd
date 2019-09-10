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
		item_data["name"] = item
		
		var item_node : Item = item_res.instance()
		inventory_container.add_child(item_node, true)
		item_node.initialize(item_data)

func _on_pressed() -> void:
	match button_group.get_pressed_button().name:
		"All":
			set_items_visibility(inventory_container.get_children(), true)
		"Equipment":
			set_items_visibility(get_tree().get_nodes_in_group("equipment"), true)
			set_items_visibility(get_tree().get_nodes_in_group("consumable"), false)
			set_items_visibility(get_tree().get_nodes_in_group("quest_object"), false)
		"Consumables":
			set_items_visibility(get_tree().get_nodes_in_group("equipment"), false)
			set_items_visibility(get_tree().get_nodes_in_group("consumable"), true)
			set_items_visibility(get_tree().get_nodes_in_group("quest_object"), false)
		"Quest_Items":
			set_items_visibility(get_tree().get_nodes_in_group("equipment"), false)
			set_items_visibility(get_tree().get_nodes_in_group("consumable"), false)
			set_items_visibility(get_tree().get_nodes_in_group("quest_object"), true)

func set_items_visibility(items: Array, visible : bool) -> void:
	for item in items:
		item.visible = visible
