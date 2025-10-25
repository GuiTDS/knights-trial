extends CharacterBody2D

const SPEED = 40.0

@onready var collision_detector := $collision_detector as RayCast2D
@onready var anim: AnimatedSprite2D = $anim

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
	
	anim.scale.x = direction  * -1 # we multiply because the sprite is inverted (right to left)
		
	velocity.x = direction * SPEED 

	move_and_slide()

func _on_anim_animation_finished() -> void:
	if anim.animation == "die":
		queue_free()


func _on_anim_animation_changed() -> void:
	if anim == null:
		return
	if anim.animation == "die":
		is_dying = true


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	anim.play("die")
