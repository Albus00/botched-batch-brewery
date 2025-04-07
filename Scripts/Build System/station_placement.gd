extends Node

var movingStation: Node2D = null
var mouse_position: Vector2

func _setMovingStation(station: Node2D) -> void:
	movingStation = station
