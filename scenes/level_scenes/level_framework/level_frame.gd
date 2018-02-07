tool
extends Spatial

export (float) var level_length = 15 setget set_level_length

func _ready():
	pass

func set_level_length(new_length):
	if not Engine.editor_hint or not has_node("level_middle"):
		return
	level_length = new_length
	$level_middle.scale = Vector3(new_length, 1, 1)
	$level_middle.translation = Vector3(10 + new_length, 0, 0)
	$level_end.translation = Vector3(15 + (2 * new_length), 0, 0)
