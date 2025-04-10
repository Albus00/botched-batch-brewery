extends CharacterBody2D

const SPEED = 250.0
var latest_direction: Vector2 = Vector2.ZERO

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	var direction := get_direction()

	if direction != Vector2.ZERO:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	animate(direction)
	move_and_slide()

func get_direction() -> Vector2:
	var input_x := Input.get_axis("ui_left", "ui_right")
	var input_y := Input.get_axis("ui_up", "ui_down")
	return Vector2(input_x, input_y).normalized()

func snap_direction(direction: Vector2) -> Vector2:
	# Snap the direction to the nearest cardinal direction
	print(direction)
	if abs(direction.y) > abs(direction.x):
		return Vector2(0, direction.y)
	else:
		return Vector2(direction.x, 0)

# Animation logic goes here
func animate(direction: Vector2) -> void:
	if direction.length() == 0:
		# Player is standing still. Use the last direction for idle animation
		play_animation("idle")
	else:
		latest_direction = snap_direction(direction)
		play_animation("walk")

func play_animation(animation: String) -> void:
		var animation_suffix = ""

		if latest_direction.x != 0:
				if latest_direction.x > 0:
						animated_sprite.flip_h = true
				else:
						animated_sprite.flip_h = false
				animation_suffix = "_s"
		elif latest_direction.y < 0:
				animation_suffix = "_u"
		elif latest_direction.y >= 0:
				animation_suffix = "_d"

		animated_sprite.play(animation + animation_suffix)
