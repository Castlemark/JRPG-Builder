extends Panel

class_name Treaseure_Menu

signal on_treasure_toggle(is_active)
signal items_taken()

var item_res := preload("res://scenes/ui/inventory/Item.tscn")

onready var GM := $"/root/Game_Manager"
onready var item_container := $Control/Scroll/GridContainer as GridContainer

func _ready() -> void:
	self.visible = false

func receive_items(treasure_data : Dictionary) -> void:
	emit_signal("on_treasure_toggle", true)
	
	var difference : int = treasure_data.items.size() - item_container.get_child_count()
	if difference > 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var item_node : Item = item_res.instance()
			item_container.add_child(item_node, true)
			item_node.disabled = true
			item_node.focus_mode = FOCUS_NONE
	elif difference < 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var node_to_delete = item_container.get_child(0)
			item_container.remove_child(node_to_delete)
			node_to_delete.queue_free()
	
	for i in range( treasure_data.items.size()):
		var item_node : Item = item_container.get_child(i) as Item
		item_node.initialize(Game_Manager.campaign_data.items.get(treasure_data.items[i]))
	
	self.visible = true

func on_click_take_all() -> void:
	for item in item_container.get_children():
		Game_Manager.campaign_data.party.inventory.append(item.data)
	
	self.visible = false
	emit_signal("on_treasure_toggle", false)
	emit_signal("items_taken")
