extends Node

var pickupbaleItems: Array[Node] = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_pickupItem()


func _pickupItem() -> void:
	if pickupbaleItems.size() > 0:
		# Add item to inventory
		var item = pickupbaleItems[0]
	

		# Remove item from scene
		item.queue_free()
		pickupbaleItems.erase(0)
		print("Picked up item")

func _on_area_entered(area: Area2D) -> void:
	pickupbaleItems.push_back(area.get_parent())

func _on_area_exited(area: Area2D) -> void:
		pickupbaleItems.erase(area.get_parent())
