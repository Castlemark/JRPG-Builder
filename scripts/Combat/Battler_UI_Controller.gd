extends Button

class_name Battler_UI_Controller

signal battler_selected(battler_data)

onready var battler_name : Label = $Name as Label

onready var lifebar : ProgressBar = $LifeBar as ProgressBar
onready var life_label : Label = $LifeBar/Label as Label

onready var energybar : ProgressBar = $EnergyBar as ProgressBar
onready var energy_label : Label = $EnergyBar/Label as Label

onready var evasion_label : Label = $Evasion as Label
onready var cur_evasion : float = 0.0
onready var critic_label : Label = $Critic as Label
onready var cur_critic : float = 0.0

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
	
	evasion_label.text = "Evasion " + String(battler_data.data.stats.evasion) + "%"
	cur_evasion = battler_data.data.stats.evasion
	critic_label.text = "Critic " + String(battler_data.data.stats.critic * 100) + "%"
	cur_critic = battler_data.data.stats.critic
	
	data = battler_data

func update_stats():
	if data.data.stats.health != lifebar.value:
		tween.interpolate_property(lifebar, "value", lifebar.value, data.data.stats.health, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		life_label.text = String(data.data.stats.health) + "/" + String(lifebar.max_value)
	
	if data.data.stats.strain != energybar.value:
		tween.interpolate_property(energybar, "value", energybar.value, data.data.stats.strain, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		energy_label.text = String(data.data.stats.strain) + "/" + String(energybar.max_value)
	
	if data.data.stats.evasion != cur_evasion:
		tween.interpolate_method(self, "_animate_evasion", cur_evasion, data.data.stats.evasion, 0.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
		cur_evasion = data.data.stats.evasion
	
	if data.data.stats.critic != cur_critic:
		tween.interpolate_method(self, "_animate_critic", cur_critic, data.data.stats.critic, 0.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
		cur_critic = data.data.stats.critic
	
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
