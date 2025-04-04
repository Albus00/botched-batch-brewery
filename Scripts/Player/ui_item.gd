# This script is for the UI item that displays the item in the inventory.
extends Node

@onready var sprite2D: Sprite2D = $Sprite2D
@onready var amountLabel: Label = $AmountLabel

func set_item(item: Item, amount: int) -> void:
	# Set the item texture
	sprite2D.texture = item.sprite

	# Set the new amount of the item
	amountLabel.text = str(amount)

func add_amount(amount: int) -> void:
	# Add the amount to the current amount
	var current_amount = int(amountLabel.text)
	current_amount += amount

	# Update the label with the new amount
	amountLabel.text = str(current_amount)
