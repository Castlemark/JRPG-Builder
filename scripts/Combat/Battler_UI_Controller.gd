extends Button

class_name Battler_UI_Controller

signal battler_selected(battler_data)

onready var battler_name : Label = $Name as Label

onready var lifebar : ProgressBar = $LifeBar as ProgressBar
onready var life_label : Label = $LifeBar/Label as Label

onready var energybar : ProgressBar = $EnergyBar as ProgressBar
onready var energy_label : Label = $EnergyBar/Label as Label

onready var evasion_label : Label = $Evasion as Label
onready var cur_evasion : int = 0
onready var critic_label : Label = $Critic as Label
onready var cur_critic : int = 0

onready var tween : Tween = $Tween as Tween

var data

func set_all_stats(name : String, cur_hp : int, total_hp : int, cur_energy : int, total_energy : int, battler_data):
	battler_name.text = name
	
	lifebar.value = cur_hp
	lifebar.max_value = total_hp
	life_label.text = String(cur_hp) + "/" + String(total_hp)
	
	energybar.value = cur_energy
	energybar.max_value = total_energy
	energy_label.text = String(cur_energy) + "/" + String(total_energy)
	
	cur_evasion = int(battler_data.data.stats_with_equipment.evasion * 100)
	evasion_label.text = "Evasion " + String(cur_evasion) + "%"
	cur_critic = int(battler_data.data.stats_with_equipment.critic * 100)
	critic_label.text = "Critic " + String(cur_critic) + "%"
	
	data = battler_data

func update_stats():
	if data.data.stats_with_equipment.health != lifebar.value:
		tween.interpolate_property(lifebar, "value", lifebar.value, data.data.stats_with_equipment.health, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		life_label.text = String(data.data.stats_with_equipment.health) + "/" + String(lifebar.max_value)
	
	if data.data.stats_with_equipment.strain != energybar.value:
		tween.interpolate_property(energybar, "value", energybar.value, data.data.stats_with_equipment.strain, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		energy_label.text = String(data.data.stats_with_equipment.strain) + "/" + String(energybar.max_value)
	
	if int(data.data.stats_with_equipment.evasion * 100) != cur_evasion:
		tween.interpolate_method(self, "_animate_evasion", cur_evasion, int(data.data.stats_with_equipment.evasion * 100), 0.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
		cur_evasion = int(data.data.stats_with_equipment.evasion * 100)
	
	if int(data.data.stats_with_equipment.critic * 100) != cur_critic:
		tween.interpolate_method(self, "_animate_critic", cur_critic, int(data.data.stats_with_equipment.critic * 100), 0.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
		cur_critic = int(data.data.stats_with_equipment.critic * 100)
	
	tween.start()

# This method is designed to be called within the tween.interpolate_method() method
func _animate_evasion(value : int) -> void:
	evasion_label.text = "Evasion " + String(value) + "%"

# This method is designed to be called within the tween.interpolate_method() method
func _animate_critic(value : int) -> void:
	critic_label.text = "Critic " + String(value) + "%"

func activate_selection() -> void:
	self.disabled = false
	self.focus_mode = FOCUS_ALL

func deactivate_selection() -> void:
	self.disabled = true
	self.focus_mode = FOCUS_NONE

func _on_Status_pressed() -> void:
	emit_signal("battler_selected", self)
