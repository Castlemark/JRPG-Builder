extends Node2D

class_name Combat

signal combat_finished()
signal turn_finished()

signal battler_animations_completed()

onready var GM := $"/root/Game_Manager"

onready var background : TextureRect = $BackgroundLayer/Background as TextureRect

onready var ally_first : Character_Combat = $Characters/Allies/First as Character_Combat
onready var ally_second : Character_Combat = $Characters/Allies/Second as Character_Combat
onready var ally_third : Character_Combat = $Characters/Allies/Third as Character_Combat

onready var enemy_first : Sprite = $Characters/Enemies/First as Enemy_Combat
onready var enemy_second : Sprite = $Characters/Enemies/Second as Enemy_Combat
onready var enemy_third : Sprite = $Characters/Enemies/Third as Enemy_Combat

onready var UI : Combat_UI_Manager = $UILayer/UI as Combat_UI_Manager

onready var attack_bg : Sprite = $Attack_BG as Sprite
onready var attack_bg_tween : Tween = $Attack_BG/Tween as Tween

var _combat_started := false
var _turn_order := []
var _cur_fighter : int = 0
var _cur_ability : Model.Ability_Data

var _yield_battler_counter := 0

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
	background.texture = GM.campaign_data.maps[GM.campaign_data.cur_map].combat_background
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
	UI.set_status()
	
	_combat_started = true
	_execute_combat_loop()

func _end_combat() -> void:
	# We reset stamina of allies
	if ally_first.visible:
		ally_first.data.stats.strain = ally_first.data.stats.max_strain
	if ally_second.visible:
		ally_second.data.stats.strain = ally_second.data.stats.max_strain
	if ally_third.visible:
		ally_third.data.stats.strain = ally_third.data.stats.max_strain
	
	# We deactivate all relevant elements
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
		priority_a = 2 * a.data.stats.speed + a.data.stats.evasion
	else:
		priority_a = 2 * a.data.stats.speed + a.data.stats.evasion
	
	var priority_b
	if b is Character_Combat:
		priority_b = 2 * b.data.stats.speed + b.data.stats.evasion
	else:
		priority_b = 2 * b.data.stats.speed + b.data.stats.evasion
	
	return priority_a > priority_b

func _execute_combat_loop() -> void:
	# Turn logic goes inside the loop
	while _combat_is_in_progress():
		print("new turn for " + _turn_order[_cur_fighter].data.name)
		
		var battler = _turn_order[_cur_fighter]
		if battler.data.stats.strain + int(battler.data.stats.max_strain / 10.0) > battler.data.stats.max_strain:
			battler.data.stats.strain = battler.data.stats.max_strain
		else:
			battler.data.stats.strain += int(battler.data.stats.max_strain / 10.0)
		UI.update_status_graphics()
		
		if battler is Enemy_Combat:
			_enemy_decide_turn(battler as Enemy_Combat)
		
		yield(self, "turn_finished")
		_cur_fighter += 1
		if _cur_fighter >= _turn_order.size():
			print("New Round")
			_update_turn_order()
		UI.indicate_cur_fighter(_cur_fighter, _turn_order)
	
	_display_combat_end()

func _combat_is_in_progress() -> bool:
	var allies_dead := true
	var enemies_dead := true
	
	for battler in _turn_order:
		if battler is Character_Combat:
			if battler.data.stats.health > 0:
				allies_dead = false
		else:
			if battler.data.stats.health > 0:
				enemies_dead = false
	
	return not (allies_dead or enemies_dead)

func _display_combat_end() -> void:
	_end_combat()

func _set_cur_ability(data) -> void:
	if data is bool:
		print("no ability chosen")
		emit_signal("turn_finished")
	else:
		_cur_ability = data

#function called when a target for the ability is chosen
func _play_ability(battler_status) -> void:
	var recevier_battler = battler_status.data
	
	var emiter : Character_Combat = _turn_order[_cur_fighter]
	
	emiter.z_index = 1
	recevier_battler.z_index = 1
	
	attack_bg_tween.interpolate_property(attack_bg, "modulate", null, Color(1, 1, 1, 0.85), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	attack_bg_tween.start()
	yield(attack_bg_tween, "tween_completed")
	
	# We apply the effect
	_apply_ability_effect(recevier_battler, emiter)
	UI.update_status_graphics()
	
	yield(self, "battler_animations_completed")
	
	# We check if receiver has died
	if recevier_battler.data.stats.health <= 0:
		recevier_battler.visible = false
		battler_status.visible = false
		var dead_index = _turn_order.find(recevier_battler)
		if dead_index <= _cur_fighter and dead_index >= 0:
			_cur_fighter -= 1
		_turn_order.erase(recevier_battler)
		UI.update_queue(_turn_order)
	
	attack_bg_tween.interpolate_property(attack_bg, "modulate", null, Color(1, 1, 1, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	attack_bg_tween.start()
	yield(attack_bg_tween, "tween_completed")
	
	emiter.z_index = 0
	recevier_battler.z_index = 0
	
	if _cur_ability.side == "enemies":
		UI.enemies_status[0].deactivate_selection()
		UI.enemies_status[1].deactivate_selection()
		UI.enemies_status[2].deactivate_selection()
	else:
		UI.allies_status[0].deactivate_selection()
		UI.allies_status[1].deactivate_selection()
		UI.allies_status[2].deactivate_selection()
	
	emit_signal("turn_finished")

func _apply_ability_effect(receiver, emiter) -> void:
	var amount : int = (round(_cur_ability.amount * emiter.data.stats.damage) as int)
	emiter.data.stats.strain -= _cur_ability.cost
	
	if amount > 0:
		emiter.play_animation("attack")
		receiver.play_animation("hit")
	else:
		emiter.play_animation("miss")
		receiver.play_animation("miss")
	
	match _cur_ability.type:
		"health":
			receiver.data.stats.health -= amount
		"evasion":
			receiver.data.stats.evasion -= amount
		"strain":
			receiver.data.stats.strain -= amount
		"damage":
			receiver.data.stats.damage -= amount

# This function decides what ability and targer will an enemy choose
func _enemy_decide_turn(enemy : Enemy_Combat) -> void:
	pass 

# This function is connected to players, when two animations are played (emiter and receiver) it notifies the interested parties
func _update_yield_counter() -> void:
	_yield_battler_counter += 1
	if _yield_battler_counter >= 2:
		emit_signal("battler_animations_completed")
		_yield_battler_counter = 0
