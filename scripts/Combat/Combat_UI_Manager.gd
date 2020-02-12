extends Control

class_name Combat_UI_Manager

signal ability_chosen(ability_data)
signal battler_selected(battler_data)
signal end_combat_summary_dismissed()

var character_ability_res : Resource = preload("res://scenes/ui/party/Character_Ability.tscn")

onready var queue_container : HBoxContainer = $Queue/HBoxContainer as HBoxContainer
onready var queue_tween : Tween = $Queue/Tween as Tween

onready var menu : Panel = $Menu as Panel
onready var submenu : Control = $Submenu as Control

onready var end_turn_button : Button = $Menu/HBoxContainer/End_Turn as Button

onready var attack_button : Button = $Menu/HBoxContainer/Attack as Button
onready var abilities_grid : GridContainer = $Submenu/Grid/Abilities/Container as GridContainer
onready var abilities_container : ScrollContainer = $Submenu/Grid/Abilities as ScrollContainer

onready var items_button : Button = $Menu/HBoxContainer/Inventory as Button
onready var items_grid : GridContainer = $Submenu/Grid/Items/Container as GridContainer
onready var items_container : ScrollContainer = $Submenu/Grid/Items as ScrollContainer

onready var end_screen := $End_Screen as End_Screen

var ability_button_group := ButtonGroup.new()

var _cur_fighter : int

var _tween_values = [Color(1, 1, 1, 1), Color(0.3, 0.3, 0.3, 1)]
const _min_turn_size := 74
const _max_turn_size := 110

var allies := []
onready var allies_status := [$Allies_Status/VBoxContainer/Status, $Allies_Status/VBoxContainer/Status2, $Allies_Status/VBoxContainer/Status3]

var enemies := []
onready var enemies_status := [$Enemies_Status/VBoxContainer/Status, $Enemies_Status/VBoxContainer/Status2, $Enemies_Status/VBoxContainer/Status3]

var cur_battler

func _ready() -> void:
	end_screen.visible = false
	end_screen.continue_button.connect("pressed", self, "_on_end_screen_dismissed")

	queue_tween.connect("tween_completed", self, "_on_tween_completed")


func get_nodes(ally_array : Array, enemy_array : Array) -> void:
	allies = ally_array
	enemies = enemy_array

	for i in range(enemies.size(), 3):
		enemies_status[i].visible = false

func indicate_cur_fighter(fighter_pos : int, turn_order : Array):
	cur_battler = turn_order[fighter_pos]

	attack_button.pressed = true
	_on_Attack_pressed()

	# We hide the menus when the cur fighter isn't a party character
	if turn_order[fighter_pos] is Character_Combat:
		menu.visible = true
		submenu.visible = true

		# TODO COntemplate case where ability can't be choosen due to low stamina
		_update_character_abilites_panel(turn_order[fighter_pos].data.abilities.values(), turn_order[fighter_pos].data.stats.strain)
		abilities_grid.get_child(0).grab_focus()
		_on_ability_released()
		_on_ability_grab(abilities_grid.get_child(0).data, abilities_grid.get_child(0).ability_icon.texture)
	else:
		menu.visible = false # TODO Remove comment when enemies end turn by themselves
		submenu.visible = false

	queue_tween.stop_all()

	_cur_fighter = fighter_pos

	var prev_fighter = fighter_pos - 1
	if fighter_pos == 0:
		prev_fighter = turn_order.size() - 1

	queue_container.get_child(prev_fighter).modulate = Color(1, 1, 1, 1)

	_tween_values = [Color(1, 1, 1, 1), Color(0.3, 0.3, 0.3, 1)]
	queue_tween.interpolate_property(queue_container.get_child(fighter_pos), "modulate", _tween_values[0], _tween_values[1], 1.5,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	queue_tween.interpolate_property(queue_container.get_child(fighter_pos), "rect_min_size", Vector2(_min_turn_size, _min_turn_size),Vector2(_max_turn_size, _max_turn_size), 0.1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	queue_tween.interpolate_property(queue_container.get_child(prev_fighter), "rect_min_size", Vector2(_max_turn_size, _max_turn_size), Vector2(_min_turn_size, _min_turn_size), 0.1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	queue_tween.start()
	yield(queue_tween, "tween_all_completed")

	_tween_values.invert()

func _update_character_abilites_panel(abilities_data : Array, stamina_left : int) -> void:
	var difference : int =  abilities_data.size() - (abilities_grid.get_child_count() - 2)

	if difference > 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var character_ability_node : Button = character_ability_res.instance()
			abilities_grid.add_child(character_ability_node, true)
			abilities_grid.move_child(character_ability_node, 0)
			character_ability_node.connect("ability_pressed", self, "_on_ability_pressed")
			character_ability_node.connect("ability_focus_entered", self, "_on_ability_grab")
			character_ability_node.connect("abilty_focus_exited", self, "_on_ability_released")
			character_ability_node.connect("ability_mouse_entered", self, "_on_ability_grab")
			character_ability_node.connect("ability_mouse_exited", self, "_on_ability_released")
			character_ability_node.group = ability_button_group
	elif difference < 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var node_to_delete = abilities_grid.get_child(0)
			abilities_grid.remove_child(node_to_delete)
			node_to_delete.queue_free()

	for i in range(abilities_data.size()):
		var ability_node : Character_Ability = abilities_grid.get_child(i) as Character_Ability
		ability_node.initialize(abilities_data[i])
		ability_node.pressed = false
		if abilities_data[i].cost > stamina_left:
			ability_node.disabled = true
			ability_node.focus_mode = FOCUS_NONE
		else:
			ability_node.disabled = false
			ability_node.focus_mode = FOCUS_ALL

func _on_tween_completed(object : Object, key : NodePath):
	queue_tween.interpolate_property(queue_container.get_child(_cur_fighter), "modulate", _tween_values[0], _tween_values[1], 1.5,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	queue_tween.start()

	_tween_values.invert()

func set_status() -> void:
	for i in range(0, allies.size()):
		if allies[i].data.stats.health == 0:
			allies_status[i].visible = false
		else:
			(allies_status[i] as Battler_UI_Controller).set_all_stats(\
				allies[i].data.name, \
				allies[i].data.stats.health, \
				allies[i].data.stats.max_health, \
				allies[i].data.stats.strain, \
				allies[i].data.stats.max_strain, \
				allies[i] \
			)

	for i in range (0, enemies.size()):
		if enemies[i].data.stats.health == 0:
			enemies_status[i].visible = false
		else:
			(enemies_status[i] as Battler_UI_Controller).set_all_stats( \
				enemies[i].data.name, \
				enemies[i].data.stats.health, \
				enemies[i].data.stats.max_health, \
				enemies[i].data.stats.strain, \
				enemies[i].data.stats.max_strain, \
				enemies[i] \
			)

func update_status_graphics() -> void:
	for i in range (0, allies.size()):
		(allies_status[i] as Battler_UI_Controller).update_stats()

	for i in range (0, enemies.size()):
		(enemies_status[i] as Battler_UI_Controller).update_stats()

func update_queue(turn_order : Array) -> void:
	for i in range(0, 6):
		if i < turn_order.size():
			(queue_container.get_child(i) as TextureRect).texture = turn_order[i].icon_sprite
		else:
			queue_container.get_child(i).visible = false

func _on_End_Turn_pressed(data) -> void:
	end_turn_button.pressed = false
	emit_signal("ability_chosen", data)

func _on_Attack_pressed() -> void:
	abilities_container.visible = true
	items_container.visible = false

func _on_Items_pressed() -> void:
	items_container.visible = true
	abilities_container.visible = false

func _on_ability_grab(data : Model.Ability_Data, preview_icon : Texture) -> void:
	_set_ability_view(data, preview_icon)

func _set_ability_view(data : Model.Ability_Data, preview_icon : Texture) -> void:
	var stats : Model.Stats_Data = cur_battler.data.stats

	($Submenu/Description/Scroll/VBoxContainer/Ttile/Icon as TextureRect).texture = preview_icon
	($Submenu/Description/Scroll/VBoxContainer/Ttile/Name as Label).text = String(data.name)
	($Submenu/Description/Scroll/VBoxContainer/Description as Label).text = String(data.description)
	($Submenu/Description/Scroll/VBoxContainer/Cost as Label).text = "Costs " + String(data.cost) + " stamina points"

	var damage : String = "Effect: " + String(round(data.amount * stats.damage)) + " " + data.type

	if data.amount == 0:
		damage = " Effect: none"
	($Submenu/Description/Scroll/VBoxContainer/Damage as Label).text = damage

func _on_ability_released() -> void:
	if ability_button_group.get_pressed_button() == null:
		($Submenu/Description/Scroll/VBoxContainer/Ttile/Icon as TextureRect).texture = null
		($Submenu/Description/Scroll/VBoxContainer/Ttile/Name as Label).text = ""
		($Submenu/Description/Scroll/VBoxContainer/Description as Label).text = ""
		($Submenu/Description/Scroll/VBoxContainer/Damage as Label).text = ""
		($Submenu/Description/Scroll/VBoxContainer/Cost as Label).text = ""
	else:
		var pressed_ability : Character_Ability = ability_button_group.get_pressed_button() as Character_Ability
		_set_ability_view(pressed_ability.data, pressed_ability.ability_icon.texture)


func _on_ability_pressed(data : Model.Ability_Data, preview_icon : Texture) -> void:
	enemies_status[0].deactivate_selection()
	enemies_status[1].deactivate_selection()
	enemies_status[2].deactivate_selection()

	allies_status[0].deactivate_selection()
	allies_status[1].deactivate_selection()
	allies_status[2].deactivate_selection()

	if data.side == "enemies":
		enemies_status[0].activate_selection()
		enemies_status[1].activate_selection()
		enemies_status[2].activate_selection()
		enemies_status[0].grab_focus()
	else:
		allies_status[0].activate_selection()
		allies_status[1].activate_selection()
		allies_status[2].activate_selection()
		allies_status[0].grab_focus()
	_on_End_Turn_pressed(data)

func on_combat_end(xp_earned : int):
	end_screen.visible = true
	queue_container.visible = false
	menu.visible = false
	submenu.visible = false

	for index in range(allies.size()):
		var ally := allies[index] as Character_Combat
		end_screen.set_char_summary_data(index, ally.data.name, xp_earned, ally.data.stats.health, ally.data.stats.max_health)

func _on_Status_battler_selected(battler_ui_button : Battler_UI_Controller) -> void:
	menu.visible = false
	submenu.visible = false
	emit_signal("battler_selected", battler_ui_button)

func _on_end_screen_dismissed():
	end_screen.visible = false

	for ally_status in allies_status:
		ally_status.visible = true
	for enemy_status in enemies_status:
		enemy_status.visible = true

	for queue_item in queue_container.get_children():
		queue_item.visible = true

	queue_container.visible = true
	menu.visible = true
	submenu.visible = true
	emit_signal("end_combat_summary_dismissed")
