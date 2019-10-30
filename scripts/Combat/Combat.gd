extends Node2D

class_name Combat

signal combat_finished()

onready var background : TextureRect = $BackgroundLayer/Background

var _combat_started := false

func _ready() -> void:
	background.visible = false
	pass

func _input(event: InputEvent) -> void:
	if _combat_started:
		if event.is_action_pressed("ui_select"):
			_end_combat()

func start_combat() -> void:
	background.visible = true
	_combat_started = true
	pass

func _end_combat() -> void:
	background.visible = false
	emit_signal("combat_finished")