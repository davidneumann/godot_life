extends Label

var last_update_time = 1
var last_count = 1
var last_iteration_count
func _on_Main_update_finished(time, count, iteration_count):
	last_update_time = time
	last_count = count
	last_iteration_count = iteration_count

var last_time = 0
func _process(delta):
	var start = OS.get_ticks_msec()
	var time = floor(start - last_time)
	var new_text = "Logic: " + str(last_update_time) + "ms"
	new_text += "\nEntity count: " + str(last_count)
	new_text += "\nDelta: " + str(time) + "ms" 
	new_text += "\n" + str(floor(time / last_count * 100) / 100) + " ms/entity"
	new_text += "\nIteration: " + str(last_iteration_count)
	self.text = new_text
	last_time = start
