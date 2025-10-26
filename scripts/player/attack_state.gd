extends State

func enter() -> void:
	player.velocity.x = 0
	player.anim.play("attack")
	player.attack_area.disabled = true
	
func physics_update(_delta: float):
	if player.anim.frame == 1:
		player.attack_area.disabled = false
	else:
		player.attack_area.disabled = true
		
	var total_frames = player.anim.sprite_frames.get_frame_count(player.anim.animation)
	if player.anim.frame == total_frames - 1:
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0: 
			state_machine.change_state(state_machine.get_node("move_state"))
		else:
			state_machine.change_state(state_machine.get_node("idle_state"))
