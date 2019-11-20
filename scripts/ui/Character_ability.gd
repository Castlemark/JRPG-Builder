extends Button

class_name Character_Ability

signal ability_pressed(ability_data, icon)

signal ability_focus_entered(ability_data, icon)
signal abilty_focus_exited()

signal ability_mouse_entered(ability_data, icon)
signal ability_mouse_exited()

onready var GM := $"/root/Game_Manager"

onready var label : Label = $VBoxContainer/Label
onready var ability_icon : TextureRect = $VBoxContainer/Icon

var data := Model.Ability_Data.new()

func initialize(ability_data) -> void:
	data = ability_data

	label.text = (data.name as String).replace("_", " ")

	var img : Texture = Utils.load_img_GUI("res://campaigns/" + GM.campaign_data.name + "/abilities/" + data.name + "/icon.png")
	if img != null:
		ability_icon.texture = img

func _on_Ability_pressed() -> void: emit_signal("ability_pressed", data, ability_icon.texture)

func _on_Ability_focus_entered() -> void: emit_signal("ability_focus_entered", data, ability_icon.texture)

func _on_Ability_mouse_entered() -> void: emit_signal("ability_mouse_entered", data, ability_icon.texture)

func _on_Ability_focus_exited() -> void: emit_signal("abilty_focus_exited")

func _on_Ability_mouse_exited() -> void: emit_signal("ability_mouse_exited")
