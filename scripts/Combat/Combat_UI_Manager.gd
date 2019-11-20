extends Control

class_name Combat_UI_Manager

signal turn_finished()

onready var queue_container : HBoxContainer = $Queue/HBoxContainer as HBoxContainer
onready var queue_tween : Tween = $Queue/Tween as Tween

var _cur_fighter : int

var _tween_values = [Color(1, 1, 1, 1), Color(0.3, 0.3, 0.3, 1)]
const _min_turn_size := 74
const _max_turn_size := 110

var allies := []
onready var allies_status := [$Allies_Status/VBoxContainer/Status, $Allies_Status/VBoxContainer/Status2, $Allies_Status/VBoxContainer/Status3]

var enemies := []
onready var enemies_status := [$Enemies_Status/VBoxContainer/Status, $Enemies_Status/VBoxContainer/Status2, $Enemies_Status/VBoxContainer/Status3]

func _ready() -> void:
	queue_tween.connect("tween_completed", self, "_on_tween_completed")

func get_nodes(ally_array : Array, enemy_array : Array) -> void:
	allies = ally_array
	enemies = enemy_array
	
	for i in range(enemies.size(), 3):
		enemies_status[i].visible = false

func indicate_cur_fighter(fighter_pos : int, battle_size : int):
	queue_tween.stop_all()
	
	_cur_fighter = fighter_pos
	
	var prev_fighter = fighter_pos - 1
	if fighter_pos == 0:
		prev_fighter = battle_size - 1
	
	queue_container.get_child(prev_fighter).modulate = Color(1, 1, 1, 1)
	
	queue_tween.interpolate_property(queue_container.get_child(fighter_pos), "modulate", _tween_values[0], _tween_values[1], 1.5,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	queue_tween.interpolate_property(queue_container.get_child(fighter_pos), "rect_min_size", Vector2(_min_turn_size, _min_turn_size),Vector2(_max_turn_size, _max_turn_size), 0.1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	queue_tween.interpolate_property(queue_container.get_child(prev_fighter), "rect_min_size", Vector2(_max_turn_size, _max_turn_size), Vector2(_min_turn_size, _min_turn_size), 0.1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	queue_tween.start()
	
	_tween_values.invert()

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
	emit_signal("turn_finished")