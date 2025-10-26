extends State

const ACCELERATION = 800.0
const FRICTION = 600.0

func enter() -> void:
	player.anim.play("run")
	
func physics_update(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction == 0:
		state_machine.change_state(state_machine.get_node("idle_state"))
		return
	
	##	Smoothly adjusts the player's horizontal speed
	## - target_speed: desired speed based on player input (-SPEED, 0, or SPEED)
	## - If a key is pressed, accelerate gradually toward target_speed using 'ACCELERATION'
	## - If no keys are pressed, decelerate gradually toward zero using 'FRICTION'
	## - Multiply by 'delta' to make acceleration/deceleration consistent regardless of frame rate,
	##   ensuring smooth movement
	var target_speed = direction * player.SPEED
	if direction:
		player.velocity.x = move_toward(player.velocity.x, target_speed, ACCELERATION * delta)
		player.anim.scale.x = direction # change player direction
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, FRICTION * delta)
	
	if Input.is_action_just_pressed("move_up") and player.is_on_floor():
		state_machine.change_state(state_machine.get_node("jump_state"))
		
	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("attack_state"))
