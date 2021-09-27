extends Node

var tile_size = 16
var zoom_level = 1
export (PackedScene) var entity_scene

func _ready():
	var viewport = get_viewport().size
	for x in viewport.x / tile_size:
		var count = 0 + (x % 2)
		for y in viewport.y / tile_size:
			if count % 2 == 0:
				var entity = entity_scene.instance()
				entity.global_position = Vector2(x * (tile_size * zoom_level), y  * (tile_size * zoom_level))
				add_child(entity)
			count += 1
	#set_scale(Vector2.ONE * 5)

func set_scale(size):
	pass
#	for i in self.get_children():
#		i.scale = size

func _process(delta):
	pass
