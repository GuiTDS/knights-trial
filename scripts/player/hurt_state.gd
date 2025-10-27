extends State

const KNOCKBACK_DURATION := 0.25

func enter() -> void:
	_apply_knockback(player.knockback)
	
	if player.health <= 0:
		state_machine.change_state(state_machine.get_node("die_state"))
		return
		
	player.anim.play("hurt")

func _apply_knockback(knockback_force := Vector2.ZERO) -> void:
	player.health -= 1
	player.emit_signal("stats_changed", player)
	
	player.velocity = knockback_force
	player.anim.modulate = Color(1, 0, 0)
	
	var t := get_tree().create_tween()
	t.parallel().tween_property(player.anim, "modulate", Color(1, 1, 1), KNOCKBACK_DURATION)
	t.parallel().tween_property(player, "velocity:x", 0.0, KNOCKBACK_DURATION)

func physics_update(_delta: float) -> void:
	var anim_name = player.anim.animation
	var frame_count = player.anim.sprite_frames.get_frame_count(anim_name)
	if anim_name != "hurt" or player.anim.frame == frame_count - 1:
		if player.is_on_floor():
			state_machine.change_state(state_machine.get_node("move_state"))
		else:
			state_machine.change_state(state_machine.get_node("jump_state"))
