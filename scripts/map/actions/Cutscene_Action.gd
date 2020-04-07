extends Generic_Action

class_name Cutscene_Action

func execute() -> void:
	print("cutscene not yet implemented")
	
	self.queue_free()
	emit_signal("finished")
