extends Control

const DEFAULT_PORT = 10309 # uh sure

func _ready():
	# connect all the callbacks related to networking
	get_tree().connect("network_peer_connected",self,"_player_connected")
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_ok")
	get_tree().connect("connection_failed",self,"_connected_fail")
	get_tree().connect("server_disconnected",self,"_server_disconnected")

func _set_status(text, is_ok): # set status labels
	if (is_ok):
		$panel/status_ok.set_text(text)
		$panel/status_fail.set_text("")
	else:
		$panel/status_ok.set_text("")
		$panel/status_fail.set_text(text)

func _player_connected(id): # player connected, begin the game!
	var game = load("res://game.tscn").instance()
	game.connect("game_finished",self,"_end_game",[],CONNECT_DEFERRED) # connect deferred so we can safely erase it from the callback
	
	#get_tree().get_root().add_child(game)
	add_child(game)
	hide() # hide lobby screen

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
	
	get_node("panel/join").set_disabled(false)
	get_node("panel/host").set_disabled(false)

func _server_disconnected():
	_end_game("Server disconnected")

### GAME MANAGEMENT FUNCTIONS ###

func _end_game(with_error=""):
	if (has_node("game")):
		#erase pong scene
		get_node("game").free() # erase immediately, otherwise network might show errors (this is why we connected deferred above)
		show()
	
	get_tree().set_network_peer(null) #remove peer
	
	get_node("panel/join").set_disabled(false)
	get_node("panel/host").set_disabled(false)
	
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
	get_node("panel/join").set_disabled(true)
	get_node("panel/host").set_disabled(true)
	_set_status("Waiting for player...",true)

func _on_join_pressed():
	var ip = get_node("panel/address").get_text()
	if (not ip.is_valid_ip_address()):
		_set_status("IP address is invalid",false)
		return
	
	var peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_client(ip,DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
	_set_status("Connecting...",true)