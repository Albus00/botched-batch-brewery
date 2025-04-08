extends Node

# Get stats from the item resource
@export var station_info: BrewingStation

# Get nodes from the scene tree
@onready var sprite2D: Sprite2D = $Sprite2D
@onready var interactPanel: Panel = $Control/Panel
@onready var interactionCollider: CollisionShape2D = $StationArea/CollisionShape2D
@onready var staticCollider: CollisionShape2D = $StaticBody2D/Collider
@onready var tile_map: TileMapLayer = $"../../TileMapLayer"

var mouse_position: Vector2
var mouse_position_start: Vector2
var station_position_start: Vector2
var isMoving: bool = false
var tile_size: int
var tile_map_scale: Vector2

func startMovingStation() -> void:
	isMoving = true
	mouse_position_start = get_viewport().get_mouse_position()
	station_position_start = self.position
	staticCollider.disabled = true
	interactionCollider.disabled = true
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup item
	interactPanel.visible = false
	sprite2D.texture = station_info.sprite
	tile_size = tile_map.tile_set.tile_size.x
	tile_map_scale = tile_map.scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if isMoving:
		move_station()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position

func move_station() -> void:
	if !isMoving:
		return

	# Get the mouse position in relation to the tile map
	var mouse_position_delta = (mouse_position - mouse_position_start) / tile_map_scale # Normalize mouse movement by tile_map scale
	var mouse_cell_movement = floor(mouse_position_delta / tile_size) # Get how many cells the mouse has moved
	# Move the station
	self.position = station_position_start + mouse_cell_movement * tile_size * tile_map_scale # Move the station to the new position


func _on_hops_area_entered(_area: Area2D) -> void:
	interactPanel.visible = true


func _on_hops_area_exited(_area: Area2D) -> void:
	interactPanel.visible = false
