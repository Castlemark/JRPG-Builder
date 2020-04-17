extends Tabs

class_name Menu_Inventory

var item_res : Resource = preload("res://scenes/ui/inventory/Item.tscn")

var item_button_group := ButtonGroup.new()

onready var inventory_container := $Items/Scroll/Grid as GridContainer
onready var button_group_inventory : ButtonGroup = ($Filter_Bar/All as CheckBox).group

onready var item_preview := $Item_Preview as Item_Preview
onready var party_preview := $Party_Preview as Party_Preview

onready var consume_dialog := $ConsumeConfirmationDialog as ConfirmationDialog
onready var equip_dialog := $EquipConfirmationDialog as ConfirmationDialog

onready var accessory_dialog : ConfirmationDialog = null

func _ready():
	update()


func update() -> void:
	if Game_Manager.campaign_data == null: 
		return
	var inventory : Array = Game_Manager.campaign_data.party.inventory
	var difference : int = inventory.size() - (inventory_container.get_child_count())
	if difference > 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var item_node : Item = item_res.instance()
			inventory_container.add_child(item_node, true)
			inventory_container.move_child(item_node, 0)
			item_node.group = item_button_group
			item_node.connect("pressed", self, "_show_item_preview")
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

	if item_button_group.get_pressed_button() == null:
		inventory_container.get_child(0).pressed = true
		_show_item_preview()
	_on_character_selected(party_preview.cur_character)

func _on_filter_pressed() -> void:
	match button_group_inventory.get_pressed_button().name:
		"All":
			_set_items_visibility(inventory_container.get_children(), true)
		"Equipment":
			_set_items_visibility(get_tree().get_nodes_in_group("equipment"), true)
			_set_items_visibility(get_tree().get_nodes_in_group("consumable"), false)
		"Consumables":
			_set_items_visibility(get_tree().get_nodes_in_group("equipment"), false)
			_set_items_visibility(get_tree().get_nodes_in_group("consumable"), true)

func _set_items_visibility(items: Array, visible : bool) -> void:
	for item in items:
		item.visible = visible

func _show_item_preview():
	var cur_item := item_button_group.get_pressed_button() as Item
	item_preview.preview(cur_item.data)
	party_preview.set_item_preview(cur_item.data)


func _on_consume_cur_item_request() -> void:
	var cur_item := item_button_group.get_pressed_button().data as Model.Item_Data.Consumable_Data
	var pos_neg := "increase" if cur_item.effect.value >= 0 else "decrease"
	
	consume_dialog.dialog_text = "You are about to consume a " +  cur_item.name +". This item will " + pos_neg + " your " + cur_item.effect.type + " by " + String(cur_item.effect.value) + ".\n\nPlease press \"OK\" to confirm."
	consume_dialog.popup()

func _on_consume_confirmed() -> void:
	var cur_item := item_button_group.get_pressed_button() as Item
	var cur_character := party_preview.cur_character
	
	var field : String = cur_item.data.effect.type
	cur_character.stats.set(field, min(cur_character.stats.get(field) + cur_item.data.effect.value, cur_character.stats.get("max_" + field)))
	
	Game_Manager.campaign_data.party.inventory.erase(cur_item.data)
	cur_item.queue_free()
	
	(inventory_container.get_child(0) as Item).grab_focus()
	(inventory_container.get_child(0) as Item).pressed = true
	item_preview.preview(inventory_container.get_child(0).data)

func _on_equip_cur_item_request() -> void:
	var cur_item := item_button_group.get_pressed_button().data as Model.Item_Data.Equipment_Item_Data
	var cur_character := party_preview.cur_character
	
	if cur_item.slot == "accessory":
		accessory_dialog = ConfirmationDialog.new()
		self.add_child(accessory_dialog)
		accessory_dialog.get_ok().visible = false
		accessory_dialog.dialog_autowrap = true
		accessory_dialog.anchor_left = 0.4
		accessory_dialog.anchor_top = 0.4
		accessory_dialog.anchor_right = 0.6
		accessory_dialog.anchor_bottom = 0.6
		accessory_dialog.add_button(cur_character.equipment.accessory_1.name, false, "1")
		accessory_dialog.add_button(cur_character.equipment.accessory_2.name, false, "2")
		var button := accessory_dialog.add_button(cur_character.equipment.accessory_3.name, false, "3")
		accessory_dialog.connect("custom_action", self, "_on_equip_accessory_confirmed")
		
		accessory_dialog.dialog_text = cur_character.name + " is about to replace it's " + cur_item.name + ". Click the accessory you want to replace."
		
		accessory_dialog.popup()
		button.grab_focus()
	else:
		var item_to_replace : Model.Item_Data.Equipment_Item_Data
		match cur_item.slot:
			"legs":
				item_to_replace = cur_character.equipment.legs
			"torso":
				item_to_replace = cur_character.equipment.torso
			"weapon":
				item_to_replace = cur_character.equipment.weapon
		
		equip_dialog.dialog_text = cur_character.name + " is about to replace it's " + item_to_replace.name + " for a " + cur_item.name + ".\n\nPlease press \"OK\" to confirm."
		equip_dialog.popup()

func _on_equip_confirmed() -> void:
	var cur_item := item_button_group.get_pressed_button() as Item
	var cur_character := party_preview.cur_character
	
	var item_to_replace : Model.Item_Data.Equipment_Item_Data
	match cur_item.data.slot:
		"legs":
			item_to_replace = cur_character.equipment.legs
			cur_character.equipment.legs = cur_item.data
		"torso":
			item_to_replace = cur_character.equipment.torso
			cur_character.equipment.torso = cur_item.data
		"weapon":
			item_to_replace = cur_character.equipment.weapon
			cur_character.equipment.weapon = cur_item.data
	
	cur_item.initialize(item_to_replace)
	
	Game_Manager.campaign_data.party.inventory.erase(cur_item.data)
	Game_Manager.campaign_data.party.inventory.append(item_to_replace)
	
	party_preview.set_item_preview(cur_item.data)

func _on_equip_accessory_confirmed(action: String) -> void:
	var cur_item := item_button_group.get_pressed_button() as Item
	var cur_character := party_preview.cur_character
	
	var item_to_replace : Model.Item_Data.Equipment_Item_Data
	match action:
		"1": 
			item_to_replace = cur_character.equipment.accessory_1
			cur_character.equipment.accessory_1 = cur_item.data
		"2":
			item_to_replace = cur_character.equipment.accessory_2
			cur_character.equipment.accessory_2 = cur_item.data
		"3":
			item_to_replace = cur_character.equipment.accessory_3
			cur_character.equipment.accessory_3 = cur_item.data
	
	cur_item.initialize(item_to_replace)
	accessory_dialog.queue_free()
	
	Game_Manager.campaign_data.party.inventory.erase(cur_item.data)
	Game_Manager.campaign_data.party.inventory.append(item_to_replace)
	
	party_preview.set_item_preview(cur_item.data)


func _on_character_selected(character_data) -> void:
	var cur_item := item_button_group.get_pressed_button() as Item
	if cur_item != null:
		var need_to_change_item_preview := false
		if cur_item.data.type != "consumable" and cur_item.data.min_level > character_data.cur_level():
			need_to_change_item_preview = true
		
		print(character_data.name + ": " + String(character_data.cur_level()))
		for item in item_button_group.get_buttons():
			if item.data.type != "consumable" and item.data.min_level > character_data.cur_level():
				(item as Item).disable(true)
			else:
				(item as Item).disable(false)
				if need_to_change_item_preview:
					item.pressed = true
					_show_item_preview()
					party_preview.set_item_preview(item.data)
					need_to_change_item_preview = false
