extends Node2D

class_name Combat

signal combat_finished()

onready var GM := $"/root/Game_Manager"

onready var background : TextureRect = $BackgroundLayer/Background as TextureRect

onready var ally_first : Character_Combat = $Characters/Allies/First as Character_Combat
onready var ally_second : Character_Combat = $Characters/Allies/Second as Character_Combat
onready var ally_third : Character_Combat = $Characters/Allies/Third as Character_Combat

onready var enemy_first : Sprite = $Characters/Enemies/First as Enemy_Combat
onready var enemy_second : Sprite = $Characters/Enemies/Second as Enemy_Combat
onready var enemy_third : Sprite = $Characters/Enemies/Third as Enemy_Combat

onready var UI : Combat_UI_Manager = $UILayer/UI as Combat_UI_Manager

var _combat_started := false
var _turn_order := []
var _cur_fighter : int = 0

func _ready() -> void:
	background.visible = false
	UI.visible = false
	pass

func _input(event: InputEvent) -> void:
	if _combat_started:
		if event.is_action_pressed("ui_select"):
			_end_combat()

func start_combat(combat_data : Dictionary) -> void:
	# TODO Disable all Menu and bind inventory
	background.visible = true
	UI.visible = true
	
	ally_first.prepare_for_combat(GM.campaign_data.party.first_character)
	ally_second.prepare_for_combat(GM.campaign_data.party.second_character)
	ally_third.prepare_for_combat(GM.campaign_data.party.third_character)
	
	match combat_data.enemies.size():
		1:
			enemy_first.visible = false
			enemy_second.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[0]))
			enemy_third.visible = false
			
			UI.get_nodes([ally_first, ally_second, ally_third], [enemy_second])
		2:
			enemy_first.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[0]))
			enemy_second.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[1]))
			enemy_third.visible = false
			
			UI.get_nodes([ally_first, ally_second, ally_third], [enemy_first, enemy_second])
		3:
			enemy_first.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[0]))
			enemy_second.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[1]))
			enemy_third.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[2]))
			
			UI.get_nodes([ally_first, ally_second, ally_third], [enemy_first, enemy_second, enemy_third])
	
	_turn_order = [ally_first, ally_second, ally_third, enemy_first, enemy_second, enemy_third]
	_update_turn_order()
	UI.indicate_cur_fighter(_cur_fighter, _turn_order)
	UI.update_status()
	
	_combat_started = true
	_execute_combat_loop()

func _end_combat() -> void:
	background.visible = false
	UI.visible = false
	
	enemy_first.visible = true
	enemy_second.visible = true
	enemy_third.visible = true
	
	ally_first.visible = true
	ally_second.visible = true
	ally_third.visible = true
	
	emit_signal("combat_finished")

func _update_turn_order() -> void:
	for i in range(_turn_order.size() - 1, -1, -1):
		if not _turn_order[i].visible:
			_turn_order.remove(i)
	
	_turn_order.sort_custom(self, "_priority_sort")
	
	UI.update_queue(_turn_order)
	
	_cur_fighter = 0

func _priority_sort(a, b):
	
	var priority_a
	if a is Character_Combat:
		priority_a = 2 * a.data.cur_stats.speed + a.data.cur_stats.dexterity
	else:
		priority_a = 2 * a.data.stats.speed + a.data.stats.dexterity
	
	var priority_b
	if b is Character_Combat:
		priority_b = 2 * b.data.cur_stats.speed + b.data.cur_stats.dexterity
	else:
		priority_b = 2 * b.data.stats.speed + b.data.stats.dexterity
	
	return priority_a > priority_b

func _execute_combat_loop() -> void:
	# Turn logic goes inside the loop
	while _combat_is_in_progress():
		print("new turn for " + _turn_order[_cur_fighter].data.name)
		
		yield(UI, "turn_finished")
		_cur_fighter += 1
		if _cur_fighter >= _turn_order.size():
			print("New Round")
			_update_turn_order()
		UI.indicate_cur_fighter(_cur_fighter, _turn_order)
	
	_display_combat_end()

func _combat_is_in_progress() -> bool:
	return true

func _display_combat_end() -> void:
	pass