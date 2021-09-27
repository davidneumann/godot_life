extends Label

func _on_Main_update_finished(time):
	self.text = str(time) + "ms"
