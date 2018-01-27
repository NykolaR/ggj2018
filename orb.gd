extends RigidBody

#var vspeed = 0
#var gravity = 0.1
var dir = Vector3()
var state = ATTACHED
var throwing = false

const THROW_STRENGTH = 10

enum ORB_STATE {ATTACHED, PHYSICS}

sync func sync_pos(pos):
	translation = pos

func _process(delta):
	if not (get_tree().network_peer == null) and is_network_master():
		rpc_unreliable("sync_pos", translation)

func _physics_process(delta):
	if state == ATTACHED:
		mode = RigidBody.MODE_KINEMATIC
		return
	
	if throwing:
		print("throw")
		apply_impulse(Vector3(), dir.normalized() * THROW_STRENGTH)
		throwing = false
	#vspeed -= gravity
	#dir.y = vspeed
	
	#move(movement, Vector3(0, 1, 0))

func _set_direction(direction, strength=THROW_STRENGTH):
	dir = direction
	throwing = true
	state = PHYSICS
	mode = RigidBody.MODE_RIGID