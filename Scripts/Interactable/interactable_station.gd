extends Node

# Get stats from the item resource
@export var station_info: BrewingStation
@export var tile_size: int = 16

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

	# TODO: Make the station snap to the actual grid
	# Attach the station to the mouse cursor and snap to the grid
	var mouse_cell_position = tile_map.local_to_map(mouse_position)
	var cell_movement = tile_map.map_to_local(mouse_cell_position) - mouse_position_start
	
	# Move the station
	self.position = station_position_start + cell_movement


func _on_hops_area_entered(_area: Area2D) -> void:
	interactPanel.visible = true


func _on_hops_area_exited(_area: Area2D) -> void:
	interactPanel.visible = false
