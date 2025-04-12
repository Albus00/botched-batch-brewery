extends Node

var pickupbaleItems: Array[Node2D] = []
var interactableStations: Array[Node2D] = []

@onready var playerInventory: PlayerInventory = $"../Inventory"
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if pickupbaleItems.size() > 0:
			_pickupItem()
		elif interactableStations.size() > 0:
			_interactStation()


func _pickupItem() -> void:
	if playerInventory.stacks.size() <= playerInventory.MAX_SIZE:
		# Add item to inventory
		var item = pickupbaleItems[0]

		playerInventory.addItem(item.item_info)

		# Remove item from scene
		item.queue_free()
		pickupbaleItems.erase(0)

func _interactStation() -> void:
	# Get the first station in the array
	var station = interactableStations[0]
	station.open_brew_panel()
	# station.startMovingStation()

	
func _on_area_entered(area: Area2D) -> void:
	match area.name:
		"StationArea":
			interactableStations.push_back(area.get_parent())
		"ItemArea":
			pickupbaleItems.push_back(area.get_parent())

func _on_area_exited(area: Area2D) -> void:
	match area.name:
		"StationArea":
			interactableStations.erase(area.get_parent())
		"ItemArea":
			pickupbaleItems.erase(area.get_parent())
