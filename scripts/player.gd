extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0
const X_COLLIDING_FORCE = 200
const AIR_FRICTION := 0.7

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var ray_right := $ray_right as RayCast2D
@onready var ray_left := $ray_left as RayCast2D
@onready var attack_area := $anim/hitbox/collision as CollisionShape2D

var is_jumping := false
var is_hurted := false
var is_dead := false
var is_attacking := false
var player_life := 4 # 5 hearts
var knockback_vector := Vector2.ZERO
var direction

func _physics_process(delta: float) -> void:
	velocity.x = 0
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
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, AIR_FRICTION)
		animation.scale.x = direction # change player direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	_set_state()
	move_and_slide()

func follow_camera(camera): 
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path

func _on_hurtbox_body_entered(_body: Node2D) -> void:
	if player_life == 0: # player is dead, show animation
		is_dead = true
		await get_tree().create_timer(1).timeout # timer to show complete animation
		queue_free() # deleting the player from the scene
	else:
		if ray_right.is_colliding():
			take_damage(Vector2(-X_COLLIDING_FORCE, -200))
		elif ray_left.is_colliding():
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

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		# maybe here we can call body.take_damagr
		body.queue_free()

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
			
