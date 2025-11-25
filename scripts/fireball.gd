extends Area2D

@export var move_speed := 100.0
var direction: Vector2
var target_position: Vector2

func _ready() -> void:
	if target_position != Vector2.ZERO:
		direction = (target_position - global_position).normalized()
		rotation = direction.angle()
	else:
		direction = Vector2.LEFT

func _process(delta: float) -> void:
	global_position += direction * move_speed * delta
