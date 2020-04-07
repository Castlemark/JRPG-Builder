extends Generic_Action

class_name Cutscene_Action

func execute() -> void:
	var current_scene : Node = $"/root/Game_Manager".current_scene
	if current_scene.name == "Map":
		var cutscene_menu : Cutscene_Menu = current_scene.cutscene_menu
		
		cutscene_menu.play_cutscene(self.data["id"])
		yield(cutscene_menu, "on_cutscene_finished")
	self.queue_free()
	emit_signal("finished")
