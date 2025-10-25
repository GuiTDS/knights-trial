extends CharacterBody2D

const SPEED = 130.0
const ACCELERATION = 800.0
const FRICTION = 600.0
const JUMP_VELOCITY = -350.0
const X_COLLIDING_FORCE = 200

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var attack_area := $anim/hitbox/collision as CollisionShape2D

var is_jumping := false
var is_hurted := false
var is_dead := false
var is_attacking := false
var player_life := 4 # 5 hearts
var knockback_vector := Vector2.ZERO
var direction

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false
		
	if Input.is_action_just_pressed("attack"):
		is_attacking = true
		
	direction = Input.get_axis("move_left", "move_right")
	#	Smoothly adjusts the player's horizontal speed
	# - target_speed: desired speed based on player input (-SPEED, 0, or SPEED)
	# - If a key is pressed, accelerate gradually toward target_speed using 'ACCELERATION'
	# - If no keys are pressed, decelerate gradually toward zero using 'FRICTION'
	# - Multiply by 'delta' to make acceleration/deceleration consistent regardless of frame rate,
	#   ensuring smooth movement
	var target_speed = direction * SPEED
	if direction:
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
		animation.scale.x = direction # change player direction
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	_set_state()
	move_and_slide()

func follow_camera(camera): 
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
	
func _set_state():
	var state = "idle"
	
	if !is_on_floor():
		state = "jump"
	elif direction != 0:
		state = "run"
	
	if is_hurted:
		state = "hurt"
		
	if is_dead:
		state = "die"
		
	if is_attacking:
		state = "attack"
		
	if animation.name != state:
		animation.play(state)

func _on_anim_animation_finished() -> void:
	if animation.animation == "attack":
		is_attacking = false

func _on_anim_frame_changed() -> void:
	if is_attacking and animation.animation == "attack":
		if animation.frame == 1:
			attack_area.disabled = false
		else:
			attack_area.disabled = true
		
		var total_frames = animation.sprite_frames.get_frame_count(animation.animation)
		if animation.frame == total_frames - 1:
			is_attacking = false
			attack_area.disabled = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if player_life == 0: # player is dead, show animation
		is_dead = true
		await get_tree().create_timer(1).timeout # timer to show complete animation
		queue_free() # deleting the player from the scene
	else:
		var attacker = area.get_parent() # enemy node reference
		if attacker.global_position.x > global_position.x:
			take_damage(Vector2(-X_COLLIDING_FORCE, -200))
		else:
			take_damage(Vector2(X_COLLIDING_FORCE, -200))
			
func take_damage(knockback_force := Vector2.ZERO, duration := 0.25):
	player_life -= 1

	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		
		var knockback_tween = get_tree().create_tween()
		knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1, 0, 0, 1) # change the player color to Red
		knockback_tween.parallel().tween_property(animation, "modulate", Color(1, 1, 1, 1), duration)
		
	is_hurted = true
	await get_tree().create_timer(.3).timeout # timer to show animation
	is_hurted = false
