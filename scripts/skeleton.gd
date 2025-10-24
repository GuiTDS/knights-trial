extends CharacterBody2D

const SPEED = 700.0
const JUMP_VELOCITY = -400.0

@onready var collision_detector := $collision_detector as RayCast2D
@onready var anim := $anim as AnimatedSprite2D

var direction := -1
var is_dying = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_dying:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if collision_detector.is_colliding():
		direction *= -1
		collision_detector.scale.x *= -1
	
	anim.flip_h = direction == -1 # flip sprite
		
	velocity.x = direction * SPEED * delta

	move_and_slide()

func _on_anim_animation_finished() -> void:
	if anim.animation == "die":
		queue_free()


func _on_anim_animation_changed() -> void:
	if anim == null:
		return
	if anim.animation == "die":
		is_dying = true
