extends Generic_Action

class_name Combat_Trigger_Action

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func execute() -> void:
	
	var current_scene : Node = $"/root/Game_Manager".current_scene
	if current_scene.name == "Map":
		current_scene.combat_viewport.start_encounter()
	pass