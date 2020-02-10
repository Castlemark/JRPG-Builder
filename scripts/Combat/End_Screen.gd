extends Panel

class_name End_Screen

# Made of Character_End_Screen nodes
onready var char_summary := [$VBoxContainer/Character_Summary, \
							$VBoxContainer/Character_Summary2, \
							$VBoxContainer/Character_Summary3]

onready var continue_button := $Button as Button

func _ready() -> void:
	char_summary[0].visible = false
	char_summary[1].visible = false
	char_summary[2].visible = false

func set_char_summary_data(index : int, char_name : String, xp_earned : int, cur_life : int , total_life : int) -> void:
	if index < 0 or index > 2:
		print("index must be between 0 and 2 (both included)")
		return

	(char_summary[index] as Character_End_Screen).show_character_summary(char_name, xp_earned, cur_life, total_life)
