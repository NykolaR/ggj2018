extends Spatial

signal game_finished

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (not get_tree().network_peer == null) and get_tree().is_network_server():
		# if server, give control of player2 node to player 2 (recursive)
		$player2.set_network_master(get_tree().get_network_connected_peers()[0])
		$player1/player/cam_y/cam_x/camera.current = true
		
		#rpc("spawn_level", "res://scenes/level_scenes/intro_level_2.tscn", $init_spawn.translation)
		#rpc("spawn_level", "res://scenes/level_scenes/levels_spawn/level4.tscn", $init_spawn.translation)
	elif not get_tree().network_peer == null:
		# else, give control to self (recursive)
		$player2.set_network_master(get_tree().get_network_unique_id())
		$player2/player/cam_y/cam_x/camera.current = true
	else:
		$player1/player/cam_y/cam_x/camera.current = true
		get_node("player2").queue_free()
	
	#add_child(preload("res://scenes/level_scenes/intro_level.tscn").instance())

func _input(event):
	if event.is_action_pressed("exit_game"):
		emit_signal("game_finished")

sync func player_set(p, color):
	print("set")
	var orby
	if p == 1:
		orby = $player1/orb/mesh
	if p == 2:
		orby = $player2/orb/mesh
	
	orby.get_surface_material(0).emission = color
	print(color)

#sync func spawn_level(level_path, transl):
#	# spawn level
#	var level = load(level_path).instance()
#	level.translation = transl
#	
#	level.get_node("level_end").connect("spawn_next_level", self, "spawn_level")
#	
#	$level_holder.add_child(level)
#	
#	if $level_holder.get_child_count() > 4:
#		$level_holder.get_child(0).queue_free()