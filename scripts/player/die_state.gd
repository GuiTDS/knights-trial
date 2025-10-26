extends State

func enter() -> void:
	player.velocity.x = 0
	player.anim.play("die")
	
func physics_update(_delta: float):
	var total_frames = player.anim.sprite_frames.get_frame_count(player.anim.animation)
	if player.anim.frame == total_frames - 1:
		player.queue_free()
	
