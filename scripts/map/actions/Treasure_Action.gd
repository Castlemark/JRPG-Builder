extends Generic_Action

class_name  Treasure_Action

func execute() -> void:
	var current_scene : Node = $"/root/Game_Manager".current_scene
	if current_scene.name == "Map":
		var treasure_menu : Treaseure_Menu = current_scene.treaseure_menu
		
		treasure_menu.receive_items(self.data)
		yield(treasure_menu, "items_taken")
	self.queue_free()
	emit_signal("finished")
