extends Generic_Action

class_name Wait_Action

func execute() -> void:
	yield(get_tree().create_timer(self.data.amount), "timeout")
	emit_signal("finished")
