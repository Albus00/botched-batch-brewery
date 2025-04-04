class_name ItemStack

var _item: Item # Internal storage for the item
var _amount: int # Internal storage for the amount

var item: Item:
	set(value):
		_item = value # Assign to the internal variable
	get:
		return _item # Return the internal variable

var amount: int:
	set(value):
		_amount = value # Assign to the internal variable
		# Update the UI or any other necessary logic here
		if _amount <= 0:
			# Handle item removal logic if needed
			pass
	get:
		return _amount # Return the internal variable

func _init(set_item: Item, set_amount: int) -> void:
	_item = set_item # Initialize the item
	_amount = set_amount # Initialize the amount