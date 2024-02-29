extends CharacterBody3D

enum HorState { IDLE, WALKING, SPRINTING, CROUCHING }
enum VerState { GROUNDED, JUMPING, FALLING, LAUNCHING, FLYING}

const SPEED = 1.2
const JUMP_VELOCITY = 6

const maxHorVel = 6

var preJump: float = 0
var coyoteTime: float = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var curHorState: HorState = HorState.IDLE
var curVerState: VerState = VerState.FALLING

func _ready():
	var tween = create_tween().set_loops(-1)
	tween.tween_interval(0.1)

func _physics_process(_dt):
	if Input.is_action_pressed("Sprint"):
		TryChangeHorState(HorState.SPRINTING)
	elif Input.is_action_pressed("Crouch"):
		TryChangeHorState(HorState.CROUCHING)
	else:
		TryChangeHorState(HorState.IDLE)

	var mult: float = 1
	if curHorState == HorState.SPRINTING:
		mult = 2
	elif curHorState == HorState.CROUCHING:
		mult = 0.3
	
	var airMult: float = 1

	if not is_on_floor():
		if velocity.y < 0:
			TryChangeVerState(VerState.FALLING)
		elif curVerState == VerState.JUMPING:
			if Input.is_action_just_released("Jump"):
				TryChangeVerState(VerState.LAUNCHING)
		else:
			curVerState = VerState.LAUNCHING
		var gravMult: int = 2
		if curVerState == VerState.JUMPING:
			gravMult = 1
		velocity.y -= gravity * _dt * gravMult
	else:
		TryChangeVerState(VerState.GROUNDED)
		airMult = 1

	preJump -= _dt
	coyoteTime -= _dt

	# Handle jump.
	if (Input.is_action_just_pressed("Jump") || preJump > 0) and (is_on_floor() || coyoteTime > 0) and TryChangeVerState(VerState.JUMPING):
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("Jump") and !is_on_floor():
		preJump = 0.1

	var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, $Arm.rotation.y)

	var curVel = Vector3(velocity.x, 0, velocity.z)
	var velChange = Vector3(direction.x * SPEED * mult * airMult, 0, direction.z * SPEED * mult * airMult)

	if direction:
		var amount: float = 1
		if (curVel + velChange).length() > maxHorVel * mult:
			amount = abs((maxHorVel * mult) - (curVel).length()) / velChange.length()
			if amount > 1:
				amount = 0
		velocity.x += velChange.x * amount
		velocity.z += velChange.z * amount
	
	if curVerState == VerState.GROUNDED:
		velocity.x -= lerp(velocity.x, 0.0, 0.8)
		velocity.z -= lerp(velocity.z, 0.0, 0.8)
	else:
		velocity.x -= lerp(velocity.x, 0.0, 0.98)
		velocity.z -= lerp(velocity.z, 0.0, 0.98)

	move_and_slide()

func TryChangeHorState(newState: HorState) -> bool:
	if newState == curHorState:
		return false

	if newState == HorState.SPRINTING && curVerState != VerState.GROUNDED:
		return false

	if newState == HorState.CROUCHING:
		$Shape.shape.height = 1.6
		if curVerState == VerState.GROUNDED:
			$Shape.position.y = -0.2
		else:
			$Shape.position.y = 0.2
			$StandArea.position.y = 0.4
	if curHorState == HorState.CROUCHING:
		if $StandArea.CheckAreaFree():
			$Shape.shape.height = 2.0
			$Shape.position.y = 0.0
			$StandArea.position.y = 0.0
		else:
			return false
	curHorState = newState
	return true

func TryChangeVerState(newState: VerState) -> bool:
	if newState == curVerState:
		return false

	if curVerState == VerState.GROUNDED && newState == VerState.FALLING:
		coyoteTime = 0.1

	if curHorState == HorState.CROUCHING:
		if $StandArea.CheckAreaFree():
			$Shape.shape.height = 2
			$Shape.position.y = 0
		else:
			return false
	curVerState = newState
	return true

func _process(_dt):
	UpdateMesh(_dt)

func UpdateMesh(_dt):
	if curHorState == HorState.CROUCHING:
		$Mesh.position.y = -0.2
		$Mesh.rotation.x = -deg_to_rad(30)
	else:
		$Mesh.position.y = 0.0
		if velocity:
			$Mesh.rotation.x = -deg_to_rad(velocity.length())
		else:
			$Mesh.rotation.x = deg_to_rad(0)
	if velocity:
		var front = Vector3(velocity.x, 0, velocity.z).normalized().signed_angle_to(Vector3.FORWARD, Vector3.DOWN)
		$Mesh.rotation.y = rotate_toward($Mesh.rotation.y, front, velocity.length() * _dt * 2)

	$Mesh.scale = Vector3(1,1,1) + (velocity / 100)

func TryUnCrouch() -> bool:
	return true
