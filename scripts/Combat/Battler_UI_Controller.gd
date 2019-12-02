extends Button

class_name Battler_UI_Controller

signal battler_selected(battler_data)

onready var battler_name : Label = $Name as Label

onready var lifebar : ProgressBar = $LifeBar as ProgressBar
onready var life_label : Label = $LifeBar/Label as Label

onready var shieldbar : ProgressBar = $ShieldBar as ProgressBar
onready var shield_label : Label = $ShieldBar/Label as Label

onready var energybar : ProgressBar = $EnergyBar as ProgressBar
onready var energy_label : Label = $EnergyBar/Label as Label

onready var tween : Tween = $Tween as Tween

var data

func set_all_stats(name : String, cur_hp : int, total_hp : int, cur_shield : int, total_shield : int, cur_energy : int, total_energy : int, battler_data):
	battler_name.text = name
	
	lifebar.value = cur_hp
	lifebar.max_value = total_hp
	life_label.text = String(cur_hp) + "/" + String(total_hp)
	
	shieldbar.value = cur_shield
	shieldbar.max_value = total_shield
	shield_label.text = String(cur_shield) + "/" + String(total_shield)
	
	energybar.value = cur_energy
	energybar.max_value = total_energy
	energy_label.text = String(cur_energy) + "/" + String(total_energy)
	
	data = battler_data

func update_stats():
	tween.interpolate_property(lifebar, "value", null, data.data.calc_stats.hp, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	life_label.text = String(data.data.calc_stats.hp) + "/" + String(lifebar.max_value)
	
	tween.interpolate_property(shieldbar, "value", null, data.data.calc_stats.shield, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	shield_label.text = String(data.data.calc_stats.shield) + "/" + String(shieldbar.max_value)
	
	tween.interpolate_property(shieldbar, "value", null, data.data.calc_stats.strain, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	energy_label.text = String(data.data.calc_stats.strain) + "/" + String(energybar.max_value)
	
	tween.start()

func activate_selection() -> void:
	self.button_mask = BUTTON_MASK_LEFT
	self.enabled_focus_mode = Control.FOCUS_ALL

func deactivate_selection() -> void:
	self.button_mask = 0
	self.enabled_focus_mode = Control.FOCUS_NONE

func _on_Status_pressed() -> void:
	emit_signal("battler_selected", self)
