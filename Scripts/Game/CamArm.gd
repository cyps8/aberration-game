extends SpringArm3D

var screenSize: Vector2
var sensitivity = 0.1

func _ready():
	screenSize = get_viewport().size

func _process(_delta):
	var mouseDelta = Input.get_last_mouse_velocity()
	Input.warp_mouse(Vector2(screenSize.x/2.0, screenSize.y/2.0))
	rotation.y += deg_to_rad(-mouseDelta.x * sensitivity * _delta)
	rotation.x += deg_to_rad(-mouseDelta.y * sensitivity * _delta)

	rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if Input.is_action_just_released("ZoomIn"):
		spring_length -= _delta * 10
		print(spring_length)
	elif Input.is_action_just_released("ZoomOut"):
		spring_length += _delta * 10

	spring_length = clamp(spring_length, 1, 5)