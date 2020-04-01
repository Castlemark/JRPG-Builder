extends Generic_Action

class_name Dialogue_Action

func execute() -> void:
	var current_scene : Node = $"/root/Game_Manager".current_scene
	if current_scene.name == "Map":
		var dialogue_menu : Menu_Dialogue = current_scene.dialogue_menu
		
		dialogue_menu.start_dialogue(self.data["id"])
		yield(dialogue_menu, "on_dialogue_finished")
	self.queue_free()
	emit_signal("finished")
