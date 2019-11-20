extends Control

class_name Combat_UI_Manager

signal turn_finished()

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
	queue_tween.connect("tween_completed", self, "_on_tween_completed")

func get_nodes(ally_array : Array, enemy_array : Array) -> void:
	allies = ally_array
	enemies = enemy_array
	
	for i in range(enemies.size(), 3):
		enemies_status[i].visible = false

func indicate_cur_fighter(fighter_pos : int, turn_order : Array):
	cur_battler = turn_order[fighter_pos]
	
	attack_button.pressed = true
	attack_button.grab_focus()
	_on_Attack_pressed()
	
	# We hide the menus when the cur fighter isn't a party character
	if turn_order[fighter_pos] is Character_Combat:
		menu.visible = true
		submenu.visible = true
		
		_update_character_abilites_panel(turn_order[fighter_pos].data.abilities.values())
	else:
		#menu.visible = false # TODO Remove comment when enemies end turn by themselves
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
	
	_tween_values.invert()

func _update_character_abilites_panel(abilities_data : Array) -> void:
	var difference : int =  abilities_data.size() - (abilities_grid.get_child_count() - 2)
	
	if difference > 0:
# warning-ignore:unused_variable
		for i in range(abs(difference)):
			var character_ability_node : Button = character_ability_res.instance()
			abilities_grid.add_child(character_ability_node, true)
			abilities_grid.move_child(character_ability_node, 0)
			character_ability_node.connect("ability_pressed", self, "_on_ability_pressed")
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

func _on_tween_completed(object : Object, key : NodePath):
	queue_tween.interpolate_property(queue_container.get_child(_cur_fighter), "modulate", _tween_values[0], _tween_values[1], 1.5,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	queue_tween.start()
	
	_tween_values.invert()

func update_status() -> void:
	for i in range(0, allies.size()):
		(allies_status[i] as Battler_UI_Controller).set_all_stats(\
			allies[i].calc_stats.hp, \
			allies[i].data.cur_calc_stats.hp, \
			allies[i].calc_stats.shield, \
			allies[i].data.cur_calc_stats.shield, \
			allies[i].calc_stats.strain, \
			allies[i].data.cur_calc_stats.strain \
		)
	
	for i in range (0, enemies.size()):
		(enemies_status[i] as Battler_UI_Controller).set_all_stats( \
			enemies[i].calc_stats.hp, \
			enemies[i].data.calc_stats.hp, \
			enemies[i].calc_stats.shield, \
			enemies[i].data.calc_stats.shield, \
			enemies[i].calc_stats.strain, \
			enemies[i].data.calc_stats.strain \
		)
	pass

func update_queue(turn_order : Array) -> void:
	for i in range(0, 6):
		if i < turn_order.size():
			(queue_container.get_child(i) as TextureRect).texture = turn_order[i].icon_sprite
		else:
			queue_container.get_child(i).visible = false

func _on_End_Turn_pressed() -> void:
	end_turn_button.pressed = false
	emit_signal("turn_finished")

func _on_Attack_pressed() -> void:
	abilities_container.visible = true
	items_container.visible = false

func _on_Items_pressed() -> void:
	items_container.visible = true
	abilities_container.visible = false

func _on_ability_pressed(data : Model.Ability_Data, preview_icon : Texture) -> void:
	var calc_stats : Model.Calc_Stats_Data = cur_battler.data.cur_calc_stats
	
#	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Icon as TextureRect).texture = preview_icon
#	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/HBoxContainer/Name as Label).text = String(data.name).replace("_", " ")
#	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Description as Label).text = data.description
#	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Level as Label).text = "Level: " + String(data.min_level)
#
#	var targets : String = "Targets "
#	match (data.target_amount as int):
#		1:
#			targets += "1 "
#		2:
#			targets += "2 "
#		3:
#			targets += "all "
#	targets += data.side
#	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Targets as Label).text = targets
#
#	var damage : String = "Damage: " + String(data.damage * calc_stats.damage) + " HP "
#	match (data.hits as int):
#		-1:
#			damage += "until miss "
#		_:
#			damage += "x " + String(data.hits)
#	if data.delay > 0:
#		var turns := " turn"
#		if data.delay != 1:
#			turns += "s"
#		damage += "in " + String(data.delay) + turns
#	if data.damage == 0:
#		damage = " Damage: none"
#	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Damage as Label).text = damage
#
#	var effect : String = "Effect: " + data.effect.type + "\n    "
#	match (data.effect.receiver as String):
#		"same":
#			effect += "Targets same character"
#		"complementary":
#			var aux_targets : PoolStringArray = targets.split(" ")
#			aux_targets.insert(2, "complementary")
#			effect += aux_targets.join(" ")
#		"opposite":
#			var aux_targets : PoolStringArray = targets.split(" ")
#			aux_targets.insert(2, "opposite")
#			if "enemies" in aux_targets:
#				aux_targets.set(3, "allies")
#			elif "allies" in aux_targets:
#				aux_targets.set(3, "enemies")
#			effect += aux_targets.join(" ")
#	effect += "\n    Applies " + String(data.effect.amount * calc_stats.damage) + " "
#	if (data.effect.duration as int) > 0:
#		var turns := " turn"
#		if data.effect.duration != 1:
#			turns += "s"
#		effect += "for " + String(data.effect.duration) + turns
#	if data.effect.type == "none":
#		effect = ""
#	($Data/HBoxContainer/Preview/Scroll/VBoxContainer/Effect as Label).text = effect