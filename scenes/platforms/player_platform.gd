tool
extends KinematicBody

enum {PLAYER_ONE, PLAYER_TWO}
export (int, "player one", "player two") var player = 0 setget set_player_enum
export (SpatialMaterial) var player_one_material
export (SpatialMaterial) var player_two_material
export (SpatialMaterial) var default_material

func _ready():
	if not Engine.editor_hint and has_node("mesh"):
		$mesh.set_surface_material(0, default_material)

func set_player_enum(new_value):
	if not Engine.editor_hint:
		return
	
	player = new_value
	if new_value == PLAYER_ONE:
		$mesh.set_surface_material(0, player_one_material)
		set_collision_layer_bit(3, true)
		set_collision_layer_bit(4, false)
		$mesh.set_layer_mask(8) #magic
	if new_value == PLAYER_TWO:
		$mesh.set_surface_material(0, player_two_material)
		set_collision_layer_bit(3, false)
		set_collision_layer_bit(4, true)
		$mesh.set_layer_mask(16) #magic

func entered_tree():
	set_player_enum(player)
