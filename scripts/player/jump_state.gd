extends State

const JUMP_VELOCITY = -350.0

func enter() -> void:
	player.velocity.y = JUMP_VELOCITY
	player.anim.play("jump")
	
func physics_update(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	player.velocity.x = direction * player.SPEED
	
	if direction != 0:
		player.anim.scale.x = direction
	
	if player.is_on_floor():
		if direction != 0:
			state_machine.change_state(state_machine.get_node("move_state"))
		else:
			state_machine.change_state(state_machine.get_node("idle_state"))
