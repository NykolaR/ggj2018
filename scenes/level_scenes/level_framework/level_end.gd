extends Spatial

var DIM = Color(0.9, 0.3, 0.3)
var LIT = Color(0.4, 0.8, 0.2)

func _ready():
	$lights/player_1.get_surface_material(0).emission = DIM
	$lights/player_1.get_surface_material(0).emission_energy = 1.7
	$lights/player_2.get_surface_material(0).emission = LIT
	$lights/player_2.get_surface_material(0).emission_energy = 4

sync func player_enter(player):
	pass