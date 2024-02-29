extends Area3D

var blockers: int = 0

func BodyEnter(_body):
	blockers += 1

func BodyExit(_body):
	blockers -= 1

func CheckAreaFree() -> bool:
	return !blockers