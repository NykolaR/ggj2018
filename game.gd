extends Spatial

signal game_finished

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (not get_tree().network_peer == null) and get_tree().is_network_server():
		# if server, give control of player2 node to player 2 (recursive)
		$player2.set_network_master(get_tree().get_network_connected_peers()[0])
	else:
		# else, give control to self (recursive)
		$player2.set_network_master(get_tree().get_network_unique_id())

func _input(event):
	if event.is_action_pressed("exit_game"):
		emit_signal("game_finished")