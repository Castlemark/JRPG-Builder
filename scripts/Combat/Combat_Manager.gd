extends Panel

class_name Combat_Manager

signal encounter_finished()
signal combat_finished()

const MIN_SIZE := -1083
const MAX_SIZE := -82

onready var tween : Tween = $Tween as Tween

var _combat_started := false

func _ready() -> void:
	self.margin_bottom = MIN_SIZE

func _input(event: InputEvent) -> void:
	if _combat_started:
		if event.is_action_pressed("ui_select"):
			emit_signal("combat_finished")

func start_encounter() -> void:
	self.grab_focus()
	
	print("starting encounter")
	tween.interpolate_property(self, "margin_bottom", null, MAX_SIZE, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	
	_start_combat()
	yield(self, "combat_finished")
	
	tween.interpolate_property(self, "margin_bottom", null, MIN_SIZE, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	
	print("ending encounter")
	emit_signal("encounter_finished")

func _start_combat() -> void:
	_combat_started = true
	pass