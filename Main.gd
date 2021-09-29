extends Node

var tile_size = 16
var zoom_level = 1
export (PackedScene) var entity_scene

var entities = {}

var max_x = 0
var max_y = 0

signal update_finished(time, count)
var started = false

func _ready():
	var viewport = get_viewport().size
	var scale_factor = tile_size * zoom_level
	max_x = viewport.x / tile_size
	max_y = viewport.y / tile_size
	for x in viewport.x / tile_size:
		var count = 0 + (x % 2)
		for y in viewport.y / tile_size:
			if count % 2 == 0:
				var entity = entity_scene.instance()
				entity.global_position = Vector2(x * scale_factor, y  * scale_factor)
				add_child(entity)
				entities[Vector2(floor(entity.global_position.x / scale_factor), floor(entity.global_position.y / scale_factor))] = entity
			count += 1
	#set_scale(Vector2.ONE * 5)
	return

func set_scale(size):
	pass
#	for i in self.get_children():
#		i.scale = size

func is_alive(position: Vector2, has_checked):
	var neighbors = 0
	var is_alive = false
	if has_checked.has(position):
		return false
	for x in range(position.x - 1, position.x + 2):
		for y in range(position.y - 1, position.y + 2):
			var check = Vector2(x,y)
			if check == position && entities.has(check):
				is_alive = true
				continue
			if entities.has(check):
				neighbors += 1
	has_checked[position] = true
	
	if is_alive:
		if neighbors < 2: # Any live cell with fewer than two live neighbours dies, as if by underpopulation.
			return false
		if neighbors == 2 || neighbors == 3: # Any live cell with two or three live neighbours lives on to the next generation.
			return true
		if neighbors > 3: # Any live cell with more than three live neighbours dies, as if by overpopulation.
			return false
	if !is_alive && neighbors == 3: # Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
		return true
	return false

func do_work():
	var start = OS.get_ticks_msec()
	var next_gen = {}
	var scale_factor = tile_size * zoom_level
	var has_checked = {}
	for key in entities.keys():
		var old_entity = entities[key]
		
		for x in range(key.x - 1, key.x + 2):
			for y in range(key.y - 1, key.y + 2):
				var pos = Vector2(x, y)
				if is_alive(pos, has_checked):# && x >= 0 && y >= 0 && x < max_x && y < max_y:
					var entity = entity_scene.instance()
					entity.global_position = Vector2(pos.x * scale_factor, pos.y  * scale_factor)
					add_child(entity)
					next_gen[pos] = entity
		old_entity.queue_free()
	entities = next_gen
	emit_signal("update_finished", OS.get_ticks_msec() - start, next_gen.size())

func handle_zoom(zoom_in, zoom_out):
	var new_zoom = $Background.zoom
	
	if zoom_in: new_zoom = new_zoom * 1.1
	if zoom_out: new_zoom = new_zoom * 0.9
	
	if new_zoom != $Background.zoom:
		var tween = $Background/Tween
		tween.interpolate_property(
			$Background,
			"zoom",
			$Background.zoom,
			new_zoom,
			0.4,
			tween.TRANS_SINE,
			# Easing out means we start fast and slow down as we reach the target value.
			tween.EASE_OUT
		)
		tween.start()
	
func _unhandled_input(event):
	handle_zoom(event.is_action_pressed("zoom_out"), event.is_action_pressed("zoom_in"))

func _process(delta):
	# do_work()
	var camera_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		camera_direction += Vector2.RIGHT
	if Input.is_action_pressed("ui_left"):
		camera_direction += Vector2.LEFT
	if Input.is_action_pressed("ui_down"):
		camera_direction += Vector2.DOWN
	if Input.is_action_pressed("ui_up"):
		camera_direction += Vector2.UP
	camera_direction = camera_direction * tile_size
	$Background.position = $Background.position + camera_direction
	
	handle_zoom(Input.is_action_pressed("zoom_out"), Input.is_action_pressed("zoom_in"))
	
	if !started && Input.is_action_pressed("start"):
		started = true
		$Timer.start()

func _on_Timer_timeout():
	do_work()
