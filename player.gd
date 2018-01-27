extends KinematicBody

var sensitivity = Vector2(-0.01, -0.003)

func _ready():
	pass

func _physics_process(delta):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		$cam_y.rotate_y(event.relative.x * sensitivity.x)
		$cam_y/cam_x.rotate_x(event.relative.y * sensitivity.y)
		$cam_y/cam_x.rotation.x = clamp($cam_y/cam_x.rotation.x, -0.5, 0.5)
		#print($cam_y/cam_x.rotation)
		#print(event.relative)