extends Generic_Action

class_name Travel_Action

func execute() -> void:
	var map_name : String = data.map_name
	var access_point : int = data.access_point
	
	$"/root/Game_Manager".travel_to_map(map_name, access_point)
	emit_signal("finished")
