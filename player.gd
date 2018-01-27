extends KinematicBody

var sensitivity = Vector2(-0.01, -0.003)
var vspeed = 0
var gravity = 0.01
const jump = 5
var movement_speed = 5

func _ready():
	pass

func _physics_process(delta):
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
	
	move_and_slide(movement)
	
	if is_on_floor():
		vspeed = 0
		print("floor")
		
		if Input.is_action_just_pressed("jump"):
			vspeed = jump

func _input(event):
	if event is InputEventMouseMotion:
		$cam_y.rotate_y(event.relative.x * sensitivity.x)
		$cam_y/cam_x.rotate_x(event.relative.y * sensitivity.y)
		$cam_y/cam_x.rotation.x = clamp($cam_y/cam_x.rotation.x, -1, 1)
		
		#print($cam_y/cam_x.rotation)
		#print(event.relative)