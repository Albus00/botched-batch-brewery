extends Node

# Get stats from the item resource
@export var item_info: Item

# Get nodes from the scene tree
@onready var sprite2D: Sprite2D = $Sprite2D
@onready var area2D: Area2D = $Area2D
@onready var interactPanel: Panel = $Control/Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup item
	interactPanel.visible = false
	sprite2D.texture = item_info.sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


<<<<<<< HEAD:Scripts/Interactable/pickupable_item.gd
func on_area_entered(_area: Area2D) -> void:
	interactPanel.visible = true


func on_area_exited(_area: Area2D) -> void:
=======
func _on_hops_area_entered(_area: Area2D) -> void:
	if item_info.inInventory:
		return
	interactPanel.visible = true


func _on_hops_area_exited(_area: Area2D) -> void:
	if item_info.inInventory:
		return
>>>>>>> 1ab7f83866b41eff1c4ad2c58227a929b1dda6e9:Scripts/pickupable_item.gd
	interactPanel.visible = false
