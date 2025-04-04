extends Node

var pickupbaleItems: Array[Node2D] = []

@onready var playerInventory: PlayerInventory = $"../Inventory"
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_pickupItem()


func _pickupItem() -> void:
	if playerInventory.stacks.size() <= playerInventory.MAX_SIZE:
		# Add item to inventory
		var item = pickupbaleItems[0]

		playerInventory.addItem(item.item_info)

		# Remove item from scene
		item.queue_free()
		pickupbaleItems.erase(0)

func _on_area_entered(area: Area2D) -> void:
	pickupbaleItems.push_back(area.get_parent())

func _on_area_exited(area: Area2D) -> void:
		pickupbaleItems.erase(area.get_parent())
