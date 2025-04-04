extends Node

@export var item_info: Item

var interactPanel: Panel


@onready var sprite2D: Sprite2D = $Sprite2D
@onready var area2D: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactPanel = get_node("Control/Panel") as Panel
	interactPanel.visible = false

	print(item_info.name)
	print(item_info.description)
	print(item_info.sprite)
	Sprite2D.texture = item_info.sprite # TODO: Fix this conversion, maybe https://www.reddit.com/r/godot/comments/1ahsk5o/swapping_sprite2ds_atlastexture_in_code/
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_hops_area_entered(_area: Area2D) -> void:
	interactPanel.visible = true


func _on_hops_area_exited(_area: Area2D) -> void:
	interactPanel.visible = false
