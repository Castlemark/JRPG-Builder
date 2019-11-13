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

var _combat_started := false
var _turn_order := []

func _ready() -> void:
	background.visible = false
	pass

func _input(event: InputEvent) -> void:
	if _combat_started:
		if event.is_action_pressed("ui_select"):
			_end_combat()

func start_combat(combat_data : Dictionary) -> void:
	# TODO Disable all Menu and bind inventory
	background.visible = true
	
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
	
	_combat_started = true
	for a in _turn_order:
		print(a.name)
	pass

func _end_combat() -> void:
	background.visible = false
	
	enemy_first.visible = true
	enemy_second.visible = true
	enemy_third.visible = true
	
	emit_signal("combat_finished")

func _update_turn_order() -> void:
	_turn_order.sort_custom(self, "_custom_sort")

func _custom_sort(a, b):
	
	var priority_a
	if a is Character_Combat:
		priority_a = 2 * a.character.cur_stats.speed + a.character.cur_stats.dexterity
	else:
		priority_a = 2 * a.enemy.stats.speed + a.enemy.stats.dexterity
	
	var priority_b
	if b is Character_Combat:
		priority_b = 2 * b.character.cur_stats.speed + b.character.cur_stats.dexterity
	else:
		priority_b = 2 * b.enemy.stats.speed + b.enemy.stats.dexterity
	
	return priority_a > priority_b