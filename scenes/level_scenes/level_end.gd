extends Spatial

enum {DIM, LIT}

const DIM_COLOR = Color(0.9, 0.3, 0.3)
const LIT_COLOR = Color(0.4, 0.8, 0.2)
const DIM_ENERGY = 1.7
const LIT_ENERGY = 4

var players_in_end = 0
var players_in_delete_level = 0
var door_open = false

signal spawn_next_level
export(String) var next_level = ""

sync func open_doors():
	if door_open:
		return
	if $door_control.is_playing():
		if (not $door_control.current_animation == "open"):
			$door_control.queue("open")
		return
	elif not door_open:
		$door_control.play("open")

sync func close_doors():
	if $door_control.is_playing():
		if (not $door_control.current_animation == "close"):
			$door_control.queue("close")
		return
	elif door_open:
		$door_control.play("close")

sync func set_light(player_one, player_two, level):
	var mat
	if player_one:
		mat = $lights/player_1.get_surface_material(0)
	if player_two:
		mat = $lights/player_2.get_surface_material(0)
	
	set_level(mat, level)

func set_level(material, level):
	if level == DIM:
		material.emission = DIM_COLOR
		material.emission_energy = DIM_ENERGY
	if level == LIT:
		material.emission = LIT_COLOR
		material.emission_energy = LIT_ENERGY

func _ready():
	if (not get_tree().network_peer == null) and is_network_master():
		rpc("set_level", $lights/player_1.get_surface_material(0), DIM)
		rpc("set_level", $lights/player_2.get_surface_material(0), DIM)

sync func end_area_change(amount):
	if is_network_master():
		players_in_end += amount
		#print(players_in_end)
		
		if players_in_end == 2:
			rpc("open_doors")
		else:
			rpc("close_doors")

sync func delete_level_change(amount):
	if is_network_master():
		players_in_delete_level += amount
		#print(players_in_delete_level)
		
		if players_in_delete_level == 2:
			rpc("delete_level")

sync func delete_level():
	#print(next_level)
	get_parent().get_parent().get_parent().rpc("spawn_level", next_level, $next_spawn.to_global($next_spawn.translation))
	#emit_signal("spawn_next_level", next_level, $next_spawn.to_global($next_spawn.translation))
	#get_parent().queue_free()

func end_area_entered( body ):
	rpc("end_area_change", 1)
	rpc("set_light", body.is_in_group("p1"), body.is_in_group("p2"), LIT)

func end_area_exited( body ):
	rpc("end_area_change", -1)
	rpc("set_light", body.is_in_group("p1"), body.is_in_group("p2"), DIM)

func close_door_entered( body ):
	rpc("delete_level_change", 1)

func close_door_exited( body ):
	rpc("delete_level_change", -1)
