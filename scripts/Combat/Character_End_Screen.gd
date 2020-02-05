extends Control

class_name Character_End_Screen

onready var character_portrait := $Portrait as TextureRect
onready var character_name := $Name as Label
onready var xp_earned := $XP_Earned as Label
onready var rem_life_bar := $Rem_Life as ProgressBar
onready var rem_life_label := $Rem_Life/Life_Label as Label
onready var tween := $Tween as Tween

const xp_msg : String = " XP points earned"

func show_character_summary( char_name : String, xp_earned : int, cur_life : int , total_life : int) -> void:
	character_name.text = char_name
	#character_portrait.texture = 
	rem_life_bar.max_value = total_life
	
	tween.interpolate_method(self, "_animate_xp", 0, xp_earned, 5.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_method(self, "_animate_rem_life", 0, cur_life, 5.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func _animate_xp(value : int) -> void:
	xp_earned.text = String(value) + xp_msg

func _animate_rem_life(value : int) -> void:
	rem_life_label.text = String(value) + "/" + String(rem_life_bar.max_value)
	rem_life_bar.value = value
