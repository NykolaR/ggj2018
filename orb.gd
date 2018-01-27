extends RigidBody

func _ready():
	pass

sync func sync_pos(pos):
	translation = pos

func _process(delta):
	if not (get_tree().network_peer == null) and is_network_master():
		rpc_unreliable("sync_pos", translation)