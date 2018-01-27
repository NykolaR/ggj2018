extends KinematicBody

const AIR_JUMPS = 1
var airJumpsRemaining = AIR_JUMPS;

var sensitivity = Vector2(-0.01, -0.003)
var vspeed = 0
var gravity = 0.1
const jump = 5
var movement_speed = 5

var controllerExists = false

onready var orb = get_parent().get_node("orb")

func _ready():
	var controllerExists = false
	var controllers = Input.get_connected_joypads()
	if controllers.size() > 0:
		controllerExists = true;

func _physics_process(delta):
	if is_network_master():
		var movement = Vector3(0, 0, 0)
		
		if controllerExists:
			#right joystick
			if Input.get_joy_axis(0, JOY_AXIS_2) > 0.2 || Input.get_joy_axis(0, JOY_AXIS_2) < -0.2:
				$cam_y.rotate_y(Input.get_joy_axis(0, JOY_AXIS_2) * -0.07)
			if Input.get_joy_axis(0, JOY_AXIS_3) > 0.2 || Input.get_joy_axis(0, JOY_AXIS_3) < -0.2:
				$cam_y/cam_x.rotate_x(Input.get_joy_axis(0, JOY_AXIS_3) * -0.07)
				$cam_y/cam_x.rotation.x = clamp($cam_y/cam_x.rotation.x, -1, 1)
			#left joystick
			if Input.get_joy_axis(0, JOY_AXIS_0) > 0.2 || Input.get_joy_axis(0, JOY_AXIS_0) < -0.2:
				movement.x += Input.get_joy_axis(0, JOY_AXIS_0)
			if Input.get_joy_axis(0, JOY_AXIS_1) > 0.2 || Input.get_joy_axis(0, JOY_AXIS_1) < -0.2:
				movement.z += Input.get_joy_axis(0, JOY_AXIS_1)
		else:
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
			if controllerExists:
				if Input.is_action_just_pressed("jump_controller"):
					vspeed = jump
			else:
				if Input.is_action_just_pressed("jump"):
					vspeed = jump
				else:
					if Input.is_action_just_pressed("jump"):
						if (airJumpsRemaining):
							vspeed = jump / 1.40
							airJumpsRemaining -= 1
		
		if orb.state == orb.ATTACHED:
			orb.translation = translation + Vector3(0, 0.2, -0.2).rotated(Vector3(0, 1, 0), $cam_y.rotation.y)
		if controllerExists:
			if Input.is_action_just_pressed("throw_controller"):
				orb.rpc("_set_direction", Vector3(-sin($cam_y.rotation.y), $cam_y/cam_x.rotation.x, -cos($cam_y.rotation.y)))
		else:
			if Input.is_action_just_pressed("throw"):
				orb.rpc("_set_direction", Vector3(-sin($cam_y.rotation.y), $cam_y/cam_x.rotation.x, -cos($cam_y.rotation.y)))

func _input(event):
	if not controllerExists:
		if event is InputEventMouseMotion:
		    $cam_y.rotate_y(event.relative.x * sensitivity.x)
		    $cam_y/cam_x.rotate_x(event.relative.y * sensitivity.y)
		    $cam_y/cam_x.rotation.x = clamp($cam_y/cam_x.rotation.x, -1, 1)