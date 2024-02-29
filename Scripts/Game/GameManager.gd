extends Node

class_name GameManager
static var instance: GameManager

var pauseRef: PauseMenu
var paused: bool = false

func _ready():
	pauseRef = $PauseMenu
	remove_child(pauseRef)

	instance = self

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func TogglePause():
	paused = !paused
	if paused:
		get_tree().paused = true
		add_child(pauseRef)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		get_tree().paused = false
		remove_child(pauseRef)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta):
	if Input.is_action_just_pressed("Pause") && !SceneManager.instance.optionsOpen:
		TogglePause()
	elif Input.is_action_just_pressed("ui_cancel") && !SceneManager.instance.optionsOpen && paused:
		TogglePause()
