extends KinematicBody

const AIR_JUMPS = 1
var airJumpsRemaining = AIR_JUMPS;

var sensitivity = Vector2(-0.01, -0.003)
var vspeed = 0
var gravity = 0.1
const jump = 5
var movement_speed = 5

onready var orb = get_parent().get_node("orb")

func _ready():
	pass

func _physics_process(delta):
	if is_network_master():
		var movement = Vector3(0, 0, 0)
		
		if Input.is_action_pressed("up"):
		    movement.z -= 1
		if Input.is_action_pressed("down"):
		    movement.z += 1
		if Input.is_action_pressed("right"):
		    movement.x += 1
		if Input.is_action_pressed("left"):
		    movement.x -= 1
		
		movement = movement.rotated(Vector3(0, 1, 0), $cam_y.rotation.y)
		movement *= movement_speed
		vspeed -= gravity
		movement.y = vspeed
		
		move_and_slide(movement, Vector3(0, 1, 0))
		
		if is_on_floor():
		    vspeed = 0
		    airJumpsRemaining = AIR_JUMPS
		    
		    if Input.is_action_just_pressed("jump"):
		    	vspeed = jump
		else:
		    if Input.is_action_just_pressed("jump"):
		    	if  (airJumpsRemaining):
		    	    vspeed = jump / 1.40
		    	    airJumpsRemaining -= 1
		
		if orb.state == orb.ATTACHED:
			orb.translation = translation + Vector3(0, 0.2, -0.2).rotated(Vector3(0, 1, 0), $cam_y.rotation.y)
		
		if Input.is_action_just_pressed("throw"):
			#var d = Vector3(-$cam_y.rotation.y, $cam_y/cam_x.rotation.x, 0)
			#var d = Vector3(0, $cam_y/cam_x.rotation.x, 0)
			#print(d)
			orb.rpc("_set_direction", Vector3(-sin($cam_y.rotation.y), $cam_y/cam_x.rotation.x, -cos($cam_y.rotation.y)))

func _input(event):
	if event is InputEventMouseMotion:
	    $cam_y.rotate_y(event.relative.x * sensitivity.x)
	    $cam_y/cam_x.rotate_x(event.relative.y * sensitivity.y)
	    $cam_y/cam_x.rotation.x = clamp($cam_y/cam_x.rotation.x, -1, 1)
	    
	    #print($cam_y/cam_x/camera.rotation)
	    #print(event.relative)