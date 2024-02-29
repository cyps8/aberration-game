extends CanvasLayer

class_name OptionsMenu

@onready var resolutionButton = $c/Box/WindowRes
@onready var windowModeButton = $c/Box/WindowMode

var confirmCountdown: float = 0
var waitingToConfirm: bool = false

var lastMode: int = 0
var lastRes: int = 1

@onready var confirmWindow: CanvasLayer = $ConfirmWindow

func _ready():
	remove_child(confirmWindow)

func BackButton():
	SceneManager.instance.CloseOptionsMenu()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") && !waitingToConfirm:
		BackButton()

	if confirmCountdown > 0 && waitingToConfirm:
		confirmCountdown -= _delta
		if confirmCountdown <= 0:
			UndoChanges()

func SelectWindowMode(_value: int, confirm: bool = true):
	match _value:
		1:
			get_window().borderless = true
			get_window().mode = Window.MODE_FULLSCREEN

			DisplayServer.window_set_size(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()))

			resolutionButton.disabled = true
		0:
			get_window().borderless = false
			get_window().mode = Window.MODE_WINDOWED

			OnResolutionChanged(resolutionButton.selected, false)

			DisplayServer.window_set_position(DisplayServer.screen_get_position() + Vector2i(0, 20))

			resolutionButton.disabled = false
		2:
			get_window().borderless = false
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN

			DisplayServer.window_set_size(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()))

			resolutionButton.disabled = true

	if confirm:
		add_child(confirmWindow)
		waitingToConfirm = true
		confirmCountdown = 5

func OnResolutionChanged(_value: int, confirm: bool = true):
	match _value:
		0:
			DisplayServer.window_set_size(Vector2i(640, 360))
		1:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		2:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		3:
			DisplayServer.window_set_size(Vector2i(3840, 2160))

	if confirm:
		add_child(confirmWindow)
		waitingToConfirm = true
		confirmCountdown = 5

func ConfirmChanges():
	waitingToConfirm = false
	lastMode = windowModeButton.selected
	lastRes = resolutionButton.selected

	remove_child(confirmWindow)

func UndoChanges():
	waitingToConfirm = false
	windowModeButton.selected = lastMode
	resolutionButton.selected = lastRes

	remove_child(confirmWindow)

	SelectWindowMode(lastMode, false)