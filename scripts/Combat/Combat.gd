extends Node2D

class_name Combat

signal combat_finished()
signal turn_finished()

onready var GM := $"/root/Game_Manager"

onready var background : TextureRect = $BackgroundLayer/Background as TextureRect

onready var ally_first : Character_Combat = $Characters/Allies/First as Character_Combat
onready var ally_second : Character_Combat = $Characters/Allies/Second as Character_Combat
onready var ally_third : Character_Combat = $Characters/Allies/Third as Character_Combat

onready var enemy_first : Sprite = $Characters/Enemies/First as Enemy_Combat
onready var enemy_second : Sprite = $Characters/Enemies/Second as Enemy_Combat
onready var enemy_third : Sprite = $Characters/Enemies/Third as Enemy_Combat

onready var UI : Control = $UILayer/UI as Control
onready var queue_container : VBoxContainer = $UILayer/UI/Queue/VBoxContainer as VBoxContainer
onready var queue_tween : Tween = $UILayer/UI/Queue/Tween as Tween

var _tween_values = [Color(1, 1, 1, 1), Color(1, 1, 1, 0.3)]

var _combat_started := false
var _turn_order := []
var _cur_fighter : int = 0


func _ready() -> void:
	queue_tween.connect("tween_completed", self, "_on_tween_completed")
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
		2:
			enemy_first.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[0]))
			enemy_second.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[1]))
			enemy_third.visible = false
		3:
			enemy_first.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[0]))
			enemy_second.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[1]))
			enemy_third.prepare_for_combat(GM.campaign_data.enemies.get(combat_data.enemies[2]))
	
	_turn_order = [ally_first, ally_second, ally_third, enemy_first, enemy_second, enemy_third]
	_update_turn_order()
	_indicate_cur_fighter()
	
	_combat_started = true
	_execute_combat_loop()

func _end_combat() -> void:
	background.visible = false
	UI.visible = true
	
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
	
	for i in range(0, 6):
		if i < _turn_order.size():
			(queue_container.get_child(i + 2) as TextureRect).texture = _turn_order[i].icon_sprite
		else:
			queue_container.get_child(i + 2).visible = false
	
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
		
		# Apply transparency via modulate to indicate selected character
		
		yield(self, "turn_finished")
		(queue_container.get_child(_cur_fighter + 2) as TextureRect).modulate = Color(1, 1, 1, 1)
		queue_tween.stop_all()
		_cur_fighter += 1
		if _cur_fighter >= _turn_order.size():
			print("New Round")
			_update_turn_order()
		_indicate_cur_fighter()
	
	_display_combat_end()

func _combat_is_in_progress() -> bool:
	return true

func _display_combat_end() -> void:
	pass

func _on_End_Turn_pressed() -> void:
	emit_signal("turn_finished")

func _indicate_cur_fighter():
	_tween_values = [Color(1, 1, 1, 1), Color(0.3, 0.3, 0.3, 1)]
	queue_tween.interpolate_property(queue_container.get_child(_cur_fighter + 2), "modulate", _tween_values[0], _tween_values[1], 1.5,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	queue_tween.start()
	
	_tween_values.invert()

func _on_tween_completed(object : Object, key : NodePath):
	queue_tween.interpolate_property(queue_container.get_child(_cur_fighter + 2), "modulate", _tween_values[0], _tween_values[1], 1.5,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	queue_tween.start()
	
	_tween_values.invert()