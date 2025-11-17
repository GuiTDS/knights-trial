extends Area2D

@export var move_speed := 100.0
var direction: Vector2
var target_position: Vector2

func _ready() -> void:
	# Se o alvo existir, calcula direção
	if target_position != Vector2.ZERO:
		print('tem posição do player %s' % target_position)
		direction = (target_position - global_position).normalized()
		rotation = direction.angle()
	else:
		# fallback: mantém movimento lateral
		direction = Vector2.LEFT

func _process(delta: float) -> void:
	global_position += direction * move_speed * delta
