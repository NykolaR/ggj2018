extends Node

const DEFAULT_PORT = 10309 # uh sure

onready var status_ok = $lobby/menu_panel/container/bottom/h/status_ok
onready var status_fail = $lobby/menu_panel/container/bottom/h/status_fail
onready var join_button = $lobby/menu_panel/container/buttons/join
onready var host_button = $lobby/menu_panel/container/buttons/host

func _ready():
	# connect all the callbacks related to networking
	get_tree().connect("network_peer_connected",self,"_player_connected")
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_ok")
	get_tree().connect("connection_failed",self,"_connected_fail")
	get_tree().connect("server_disconnected",self,"_server_disconnected")

func _set_status(text, is_ok): # set status labels
	if (is_ok):
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)

func _player_connected(id): # player connected, begin the game!
	var game = load("res://scenes/management/game.tscn").instance()
	$lobby_cam.current = false
	game.connect("game_finished",self,"_end_game",[],CONNECT_DEFERRED) # connect deferred so we can safely erase it from the callback
	
	#get_tree().get_root().add_child(game)
	$game_holder.add_child(game)
	$lobby.hide() # hide lobby screen
	
	if is_network_master():
		print("mast")
		#game.player_set(1, $lobby/menu_panel/container/bottom/color/color.modulate)
		game.rpc("player_set", 1, $lobby/menu_panel/container/bottom/color/color.modulate)
	else:
		game.rpc("player_set", 2, $lobby/menu_panel/container/bottom/color/color.modulate)

func _player_disconnected(id):
	if (get_tree().is_network_server()):
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")

func _connected_ok(): # does nothing but is set to callback for clients
	pass

func _connected_fail(): # callback from scenetree for clients
	_set_status("Couldn't connect",false)
	
	get_tree().set_network_peer(null) #remove peer
	
	$lobby_cam.current = true
	join_button.set_disabled(false)
	host_button.set_disabled(false)

func _server_disconnected():
	_end_game("Server disconnected")

### GAME MANAGEMENT FUNCTIONS ###

func _end_game(with_error=""):
	if (has_node("game_holder/game")):
		#erase pong scene
		$game_holder/game.free() # erase immediately, otherwise network might show errors (this is why we connected deferred above)
		$lobby.show()
	
	get_tree().set_network_peer(null) #remove peer
	
	$lobby_cam.current = true
	join_button.set_disabled(false)
	host_button.set_disabled(false)
	
	_set_status(with_error,false)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_host_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = peer.create_server(DEFAULT_PORT,1) # max: 1 peer, since it's a 2 players game
	if (err!=OK):
		#is another server running?
		_set_status("Can't host, address in use.",false)
		return
	
	get_tree().set_network_peer(peer)
	host_button.set_disabled(true)
	_set_status("Waiting for player...",true)

func _on_join_pressed():
	var ip = $lobby/menu_panel/container/address_bar/address.get_text()
	if (not ip.is_valid_ip_address()):
		_set_status("IP address is invalid",false)
		return
	
	var peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_client(ip,DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
	_set_status("Connecting...",true)