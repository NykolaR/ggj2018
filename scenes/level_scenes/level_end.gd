extends Spatial

enum {DIM, LIT}

const DIM_COLOR = Color(0.9, 0.3, 0.3)
const LIT_COLOR = Color(0.4, 0.8, 0.2)
const DIM_ENERGY = 1.7
const LIT_ENERGY = 4

sync func set_level(material, level):
	if level == DIM:
		material.emission = DIM_COLOR
		material.emission_energy = DIM_ENERGY
	if level == LIT:
		material.emission = LIT_COLOR
		material.emission_energy = LIT_ENERGY

func _ready():
	if is_network_master():
		rpc("set_level", $lights/player_1.get_surface_material(0), DIM)
		rpc("set_level", $lights/player_2.get_surface_material(0), DIM)

sync func player_enter(player):
	pass