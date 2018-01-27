extends RigidBody

func _ready():
	pass

sync func sync_pos():
	translation = translation

func _process(delta):
	rpc_unreliable("sync_pos", translation)