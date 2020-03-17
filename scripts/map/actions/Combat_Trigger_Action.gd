extends Generic_Action

class_name Combat_Trigger_Action

func execute() -> void:
	var current_scene : Node = $"/root/Game_Manager".current_scene
	if current_scene.name == "Map":
		var combat_viewport : Combat_Viewport = current_scene.combat_viewport
		
		combat_viewport.start_encounter(self.data)
		yield(combat_viewport, "on_combat_finished")
	self.queue_free()
	emit_signal("finished")
