class_name PlayerInventory
extends Node2D

const MAX_SIZE := 4

var stacks: Array[ItemStack] = []
@export var itemSlots: Array[Node2D] = []

func _ready() -> void:
  # Initialize the inventory with empty stacks
  for i in range(MAX_SIZE):
    stacks.append(null)
    itemSlots[i].visible = false

func addItem(item: Item) -> void:
  # If the item doesn't exist, find an empty slot
  for i in range(MAX_SIZE):
    if stacks[i] == null:
      # Create a new stack for the item
      stacks[i] = ItemStack.new(item, 1)
      itemSlots[i].visible = true
      itemSlots[i].set_item(item, stacks[i].amount)
      return
    # If the stack is not empty, check if the item is the same
    if stacks[i].item == item:
      # If the item already exists in the stack, increase the amount
      stacks[i].amount += 1
      itemSlots[i].add_amount(1)
      return

  # If the inventory is full, you can choose to do nothing or handle it differently
  print("Inventory is full!")
