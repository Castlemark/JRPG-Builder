extends Tabs

class_name Menu_Inventory

var item_res : Resource = preload("res://scenes/ui/inventory/Item.tscn")

var item_button_group := ButtonGroup.new()

onready var GM := $"/root/Game_Manager"
onready var inventory_container : GridContainer = $Scroll/Grid as GridContainer
onready var button_group_inventory : ButtonGroup = ($"Filter bar/All" as CheckBox).group

func _ready():
	pass


func update() -> void:
	if GM.campaign_data == null: 
		return
	# TODO reuse items when possible
	var inventory : Array = GM.campaign_data.party.inventory
	var difference : int = inventory.size() - (inventory_container.get_child_count())
	if difference > 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var item_node : Item = item_res.instance()
			inventory_container.add_child(item_node, true)
			inventory_container.move_child(item_node, 0)
			item_node.group = item_button_group
	elif difference < 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var node_to_delete = inventory_container.get_child(0)
			inventory_container.remove_child(node_to_delete)
			node_to_delete.queue_free()
	
	
	for i in range(inventory.size()):
		var item_node : Item = inventory_container.get_child(i)
		item_node.initialize(inventory[i])
		item_node.group = item_button_group

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

func _set_items_visibility(items: Array, visible : bool) -> void:
	for item in items:
		item.visible = visible
