extends Generic_Action

class_name Combat_Trigger_Action

func execute() -> void:
	
	var current_scene : Node = $"/root/Game_Manager".current_scene
	if current_scene.name == "Map":
		current_scene.combat_viewport.start_encounter(self.data)
	self.queue_free()
