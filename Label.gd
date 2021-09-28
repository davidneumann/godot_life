extends Label

var last_update_time = 0
var last_count = 0
func _on_Main_update_finished(time, count):
	last_update_time = time
	last_count = count

var last_time = 0
func _process(delta):
	var start = OS.get_ticks_msec()
	var time = floor(start - last_time)
	self.text = "Logic: " + str(last_update_time) + "ms" + "\nCount: " + str(last_count) + "\nDelta: " + str(time) + "ms" + "\n" + str(floor(time / last_count * 100) / 100) + " ms/entity"
	last_time = start
