extends Node

var interactPanel: Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactPanel = get_node("Control/Panel") as Panel
	interactPanel.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_hops_area_entered(_area: Area2D) -> void:
	interactPanel.visible = true


func _on_hops_area_exited(_area: Area2D) -> void:
	interactPanel.visible = false
