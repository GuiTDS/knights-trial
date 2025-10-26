extends State

func enter() -> void:
	player.anim.play("idle")
	
func physics_update(_delta: float) -> void:
	player.velocity.x = 0
	
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		state_machine.change_state(state_machine.get_node("move_state"))
		
	if Input.is_action_just_pressed("move_up") and player.is_on_floor():
		state_machine.change_state(state_machine.get_node("jump_state"))
		
	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("attack_state"))
