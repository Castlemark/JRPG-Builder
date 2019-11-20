extends Panel

class_name Battler_UI_Controller

onready var battler_name : Label = $Name as Label

onready var lifebar : ProgressBar = $LifeBar as ProgressBar
onready var life_label : Label = $LifeBar/Label as Label

onready var shieldbar : ProgressBar = $ShieldBar as ProgressBar
onready var shield_label : Label = $ShieldBar/Label as Label

onready var energybar : ProgressBar = $EnergyBar as ProgressBar
onready var energy_label : Label = $EnergyBar/Label as Label

func set_all_stats(cur_hp : int, total_hp : int, cur_shield : int, total_shield : int, cur_energy : int, total_energy : int):
	lifebar.value = cur_hp
	lifebar.max_value = total_hp
	life_label.text = String(cur_hp) + "/" + String(total_hp)
	
	shieldbar.value = cur_shield
	shieldbar.max_value = total_shield
	shield_label.text = String(cur_shield) + "/" + String(total_shield)
	
	energybar.value = cur_energy
	energybar.max_value = total_energy
	energy_label.text = String(cur_energy) + "/" + String(total_energy)