extends Node2D

class_name Combat

signal combat_finished()

onready var background : TextureRect = $BackgroundLayer/Background as TextureRect

onready var ally_first : Character_Combat = $Characters/Allies/First as Character_Combat
onready var ally_second : Character_Combat = $Characters/Allies/Second as Character_Combat
onready var ally_third : Character_Combat = $Characters/Allies/Third as Character_Combat

onready var enemy_first : Sprite = $Characters/Enemies/First as Sprite
onready var enemy_second : Sprite = $Characters/Enemies/Second as Sprite
onready var enemy_third : Sprite = $Characters/Enemies/Third as Sprite

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
	
	ally_first.prepare_for_combat()
	ally_second.prepare_for_combat()
	ally_third.prepare_for_combat()
	
	_combat_started = true
	pass

func _end_combat() -> void:
	background.visible = false
	emit_signal("combat_finished")