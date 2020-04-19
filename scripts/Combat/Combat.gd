extends Node2D

class_name Combat

signal combat_finished()
signal turn_finished()

signal battler_animations_completed()
signal turn_animations_completed()

const ACTIVE_POS = 0

onready var background := $BackgroundLayer/Background as TextureRect

onready var ally_first := $Characters/Allies/First as Character_Combat
onready var ally_second := $Characters/Allies/Second as Character_Combat
onready var ally_third := $Characters/Allies/Third as Character_Combat

onready var enemy_first := $Characters/Enemies/First as Enemy_Combat
onready var enemy_second := $Characters/Enemies/Second as Enemy_Combat
onready var enemy_third := $Characters/Enemies/Third as Enemy_Combat

onready var chars_tween := $Characters/Tween as Tween

onready var UI := $UILayer/UI as Combat_UI_Manager

onready var attack_bg := $Attack_BG as Sprite
onready var attack_bg_tween := $Attack_BG/Tween as Tween

onready var timer := $Timer as Timer

var _combat_started := false
var _turn_order := []
var _cur_fighter : int = 0
var _cur_ability : Model.Ability_Data
var _xp_reward : int = 0

var _yield_battler_counter := 0
var _yield_battler_counter_target := 2

func _ready() -> void:
	background.visible = false
	UI.visible = false
	UI.connect("end_combat_summary_dismissed", self, "_end_combat")

func start_combat(combat_data : Dictionary) -> void:
	# TODO Disable all Menu and bind inventory
	background.texture = Game_Manager.campaign_data.maps[Game_Manager.campaign_data.cur_map].combat_background
	background.visible = true
	UI.visible = true
	
	UI.begin_label.visible = true
	attack_bg.modulate = Color(1, 1, 1, 1)

	ally_first.prepare_for_combat(Game_Manager.campaign_data.party.first_character)
	ally_second.prepare_for_combat(Game_Manager.campaign_data.party.second_character)
	ally_third.prepare_for_combat(Game_Manager.campaign_data.party.third_character)

	match combat_data.enemies.size():
		1:
			enemy_first.visible = false
			enemy_second.prepare_for_combat(Game_Manager.campaign_data.enemies.get(combat_data.enemies[0]))
			enemy_third.visible = false

			_xp_reward = enemy_second.data.xp_reward
			UI.get_nodes([ally_first, ally_second, ally_third], [enemy_second])
		2:
			enemy_first.prepare_for_combat(Game_Manager.campaign_data.enemies.get(combat_data.enemies[0]))
			enemy_second.prepare_for_combat(Game_Manager.campaign_data.enemies.get(combat_data.enemies[1]))
			enemy_third.visible = false

			_xp_reward = enemy_first.data.xp_reward + enemy_second.data.xp_reward
			UI.get_nodes([ally_first, ally_second, ally_third], [enemy_first, enemy_second])
		3:
			enemy_first.prepare_for_combat(Game_Manager.campaign_data.enemies.get(combat_data.enemies[0]))
			enemy_second.prepare_for_combat(Game_Manager.campaign_data.enemies.get(combat_data.enemies[1]))
			enemy_third.prepare_for_combat(Game_Manager.campaign_data.enemies.get(combat_data.enemies[2]))

			_xp_reward = enemy_first.data.xp_reward + enemy_second.data.xp_reward + enemy_third.data.xp_reward
			UI.get_nodes([ally_first, ally_second, ally_third], [enemy_first, enemy_second, enemy_third])

	_turn_order = [ally_first, ally_second, ally_third, enemy_first, enemy_second, enemy_third]
	_update_turn_order()
	UI.indicate_cur_fighter(_cur_fighter, _turn_order)
	UI.set_status()
	

	ally_first.visible = false if ally_first.data.stats_with_equipment.health == 0 else true
	ally_second.visible = false if ally_second.data.stats_with_equipment.health == 0 else true
	ally_third.visible = false if ally_third.data.stats_with_equipment.health == 0 else true

	_combat_started = true
	randomize()
	UI.toggle_menus(false)
	_execute_combat_loop()

func _end_combat() -> void:
	# We reset stamina of allies
	_reset_character_after_combat(ally_first)
	_reset_character_after_combat(ally_second)
	_reset_character_after_combat(ally_third)

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

func _reset_character_after_combat(character : Character_Combat):
	character.data.stats_with_equipment.strain = character.data.stats_with_equipment.max_strain
	character.data.stats_with_equipment.evasion = character.data.stats_with_equipment.max_evasion
	character.data.stats_with_equipment.damage = character.data.stats_with_equipment.max_damage

func _update_turn_order() -> void:
	for i in range(_turn_order.size() - 1, -1, -1):
		if _turn_order[i].data.stats_with_equipment.health == 0:
			_turn_order.remove(i)

	_turn_order.sort_custom(self, "_priority_sort")

	UI.update_queue(_turn_order)

	_cur_fighter = 0

func _priority_sort(a, b):

	var priority_a
	if a is Character_Combat:
		priority_a = 2 * a.data.stats_with_equipment.speed + a.data.stats_with_equipment.evasion
	else:
		priority_a = 2 * a.data.stats_with_equipment.speed + a.data.stats_with_equipment.evasion

	var priority_b
	if b is Character_Combat:
		priority_b = 2 * b.data.stats_with_equipment.speed + b.data.stats_with_equipment.evasion
	else:
		priority_b = 2 * b.data.stats_with_equipment.speed + b.data.stats_with_equipment.evasion

	return priority_a > priority_b

func _execute_combat_loop() -> void:
	timer.start(2.0)
	yield(timer, "timeout")
	UI.begin_label.visible = false
	attack_bg_tween.interpolate_property(attack_bg, "modulate", null, Color(1, 1, 1, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	attack_bg_tween.start()
	yield(attack_bg_tween, "tween_completed")
	UI.toggle_menus(true)
	
	# Turn logic goes inside the loop
	while _combat_is_in_progress():
		print("new turn for " + _turn_order[_cur_fighter].data.name)

		var battler = _turn_order[_cur_fighter]
		if battler.data.stats_with_equipment.strain + int(battler.data.stats_with_equipment.max_strain / 10.0) > battler.data.stats_with_equipment.max_strain:
			battler.data.stats_with_equipment.strain = battler.data.stats_with_equipment.max_strain
		else:
			battler.data.stats_with_equipment.strain += int(battler.data.stats_with_equipment.max_strain / 10.0)
		UI.update_status_graphics()

		if battler is Enemy_Combat:
			_enemy_decide_turn(battler)

		yield(self, "turn_finished")
		_cur_fighter += 1
		if _cur_fighter >= _turn_order.size():
			print("New Round")
			_update_turn_order()
		UI.indicate_cur_fighter(_cur_fighter, _turn_order)

	print("ending combat")
	UI.on_combat_end(_xp_reward)

func _combat_is_in_progress() -> bool:
	var allies_dead := true
	var enemies_dead := true

	for battler in _turn_order:
		if battler is Character_Combat:
			if battler.data.stats_with_equipment.health > 0:
				allies_dead = false
		else:
			if battler.data.stats_with_equipment.health > 0:
				enemies_dead = false

	return not (allies_dead or enemies_dead)

func _set_cur_ability(data) -> void:
	if data is bool:
		print("no ability chosen")
		emit_signal("turn_finished")
	else:
		_cur_ability = data

#function called when a target for the ability is chosen the variable is the ui for the target
func _play_ability(receiver_battler_ui : Battler_UI_Controller) -> void:
	var recevier_battler = receiver_battler_ui.data

	var emiter = _turn_order[_cur_fighter]

	emiter.z_index = 1
	recevier_battler.z_index = 1

	attack_bg_tween.interpolate_property(attack_bg, "modulate", null, Color(1, 1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	attack_bg_tween.start()
	yield(attack_bg_tween, "tween_completed")

	# We apply the effect
	_yield_battler_counter = 1 if recevier_battler == emiter else 2
	_apply_ability_effect(recevier_battler, emiter)

	yield(self, "turn_animations_completed")

	# We check if receiver has died
	if recevier_battler.data.stats_with_equipment.health <= 0:
		recevier_battler.visible = false
		receiver_battler_ui.visible = false
		var dead_index = _turn_order.find(recevier_battler)
		if dead_index <= _cur_fighter and dead_index >= 0:
			_cur_fighter -= 1
		_turn_order.erase(recevier_battler)
		UI.update_queue(_turn_order)

	timer.start(0.5)
	yield(timer, "timeout")
	attack_bg_tween.interpolate_property(attack_bg, "modulate", null, Color(1, 1, 1, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	attack_bg_tween.start()
	yield(attack_bg_tween, "tween_completed")
	timer.start(0.5)
	yield(timer, "timeout")

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
	var amount : int = (round(_cur_ability.amount * emiter.data.stats_with_equipment.damage) as int)
	emiter.data.stats_with_equipment.strain -= _cur_ability.cost

	var receiver_pos : float = receiver.position.x
	var emiter_pos : float= emiter.position.x

	var turn_description := "[center]" + _cur_ability.name + "\n"

	var are_allies : bool = emiter.TYPE == receiver.TYPE
	var evades : bool = randf() < receiver.data.stats_with_equipment.evasion
	print("Evades: " + String(evades))
	var is_critic : bool = randf() < emiter.data.stats_with_equipment.critic
	if is_critic:
		amount = int(amount * 1.5) 
		turn_description = "[center][color=yellow]" + _cur_ability.name + " is critic![/color]\n and "


	if are_allies or not evades:
		var str_amount := ("[color=red]" if amount > 0 else  "[color=green]") + String(amount) + "[/color]"
		turn_description += "deals " + str_amount + " to " + _cur_ability.type + "[/center]"
		match _cur_ability.type:
			"health":
				receiver.data.stats_with_equipment.health = receiver.data.stats_with_equipment.health - amount if (receiver.data.stats_with_equipment.health - amount > 0) else 0
			"evasion":
				receiver.data.stats_with_equipment.evasion = receiver.data.stats_with_equipment.evasion - amount if (receiver.data.stats_with_equipment.evasion - amount > 0) else 0
			"strain":
				receiver.data.stats_with_equipment.strain = receiver.data.stats_with_equipment.strain - amount if (receiver.data.stats_with_equipment.strain - amount > 0) else 0
			"damage":
				receiver.data.stats_with_equipment.damage = receiver.data.stats_with_equipment.damage - amount if (receiver.data.stats_with_equipment.damage - amount > 0) else 0
	else:
		turn_description = "[center][color=red]" + _cur_ability.name + " misses![/color][/center]"
	UI.show_turn_log(turn_description)

	chars_tween.interpolate_property(receiver, "position:x", null, ACTIVE_POS, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	chars_tween.interpolate_property(emiter, "position:x", null, ACTIVE_POS, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	chars_tween.start()
	yield(chars_tween, "tween_all_completed")

	if amount > 0 and not evades:
		emiter.play_animation("attack")
		receiver.play_animation("hit")
	elif amount > 0 and evades:
		emiter.play_animation("attack")
		receiver.play_animation("miss")
	else:
		emiter.play_animation("miss")
		receiver.play_animation("miss")

	yield(self, "battler_animations_completed")

	UI.update_status_graphics()

	timer.start(0.5)
	yield(timer, "timeout")

	chars_tween.interpolate_property(receiver, "position:x", null, receiver_pos, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	chars_tween.interpolate_property(emiter, "position:x", null, emiter_pos, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	chars_tween.start()
	yield(chars_tween, "tween_all_completed")
	UI.turn_description.visible = false
	emit_signal("turn_animations_completed")

# This function decides what ability and target will an enemy choose, then executes it's turn
func _enemy_decide_turn(enemy : Enemy_Combat) -> void:
	var ui_allies_status := []
	var ui_enemies_status := []
	for i in range(3):
		var ally_battler_ui : Battler_UI_Controller = UI.allies_status[i]
		if ally_battler_ui.visible == true:
			ui_allies_status.append(ally_battler_ui)

		var enemy_battler_ui : Battler_UI_Controller = UI.enemies_status[i]
		if enemy_battler_ui.visible == true:
			ui_enemies_status.append(enemy_battler_ui)

	var index : int = randi() % enemy.data.abilities.size()
	var choosen_ability : Model.Ability_Data = enemy.data.abilities.values()[index]
	_set_cur_ability(choosen_ability)

	print("	choosen ability: " + choosen_ability.name + " ; with side " + choosen_ability.side)

	var choosen_battler : Battler_UI_Controller
	# we flip the selection because for the enemies, their enemies are our allies
	if choosen_ability.side == "enemies":
		choosen_battler = ui_allies_status[randi() % ui_allies_status.size()]
	else:
		choosen_battler = ui_enemies_status[randi() % ui_enemies_status.size()]

	print("	choosen target: " + choosen_battler.data.data.name)

	_play_ability(choosen_battler)


# This function is connected to players, when two animations are played (emiter and receiver) it notifies the interested parties
func _update_yield_counter() -> void:
	_yield_battler_counter += 1
	if _yield_battler_counter >= _yield_battler_counter_target:
		emit_signal("battler_animations_completed")
		_yield_battler_counter = 0
