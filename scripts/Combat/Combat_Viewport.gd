extends Panel

class_name Combat_Viewport

signal encounter_finished()

const MIN_SIZE := -1083
const MAX_SIZE := 43

onready var tween : Tween = $Tween as Tween

# Min Resolution for the viewport is 1472x934, but can get wider
onready var viewport : Viewport = $ViewportContainer/Viewport as Viewport
onready var combat_controller : Combat = $ViewportContainer/Viewport/Combat as Combat

func _ready() -> void:
	$ViewportContainer.visible = false
	self.margin_bottom = MIN_SIZE

func start_encounter(combat_data : Dictionary) -> void:
	
	print("starting encounter")
	combat_controller.start_combat(combat_data)
	tween.interpolate_property(self, "margin_bottom", null, MAX_SIZE, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	$ViewportContainer.visible = true
	yield(combat_controller, "combat_finished")
	
	$ViewportContainer.visible = false
	tween.interpolate_property(self, "margin_bottom", null, MIN_SIZE, 0.4, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	
	print("ending encounter")
	emit_signal("encounter_finished")
