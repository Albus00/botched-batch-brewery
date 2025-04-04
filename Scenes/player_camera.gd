extends Camera2D

@export var zoom_in_level := Vector2(0.5, 0.5)
@export var zoom_out_level := Vector2(1, 1)
@export var zoom_speed := 2.0

var target_zoom: Vector2


func _ready():
	target_zoom = zoom


func _process(delta):
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)


func zoom_in():
	target_zoom = zoom_in_level


func zoom_out():
	target_zoom = zoom_out_level
