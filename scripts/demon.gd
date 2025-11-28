extends CharacterBody2D

const FIREBALL = preload("res://world/prefabs/fireball.tscn")

@export var speed := 100.0
@export var respawn_time := 60.0

# spawn offsets
const SPAWN_OFFSET_X = -300.0
const SPAWN_OFFSET_Y = -150.0

@onready var path_follow: PathFollow2D = $"../path2D/path_follow2D"
@onready var anim: AnimatedSprite2D = $anim
@onready var fireball_spawn_point: Marker2D = $fireball_spawn_point

var is_active := false
var is_paused := false
var already_attacked := false

func _ready() -> void:
	hide()
	set_physics_process(false)
	_start_spawn_timer()


func _start_spawn_timer() -> void:
	await get_tree().create_timer(respawn_time).timeout
	var world = get_parent().get_parent().get_parent()
	world.toggle_camera_movement()
	_spawn_enemy_near_player()


func _spawn_enemy_near_player() -> void:
	var world = get_parent().get_parent().get_parent()
	var player = world.get_node_or_null("player")

	if player == null:
		_start_spawn_timer()
		return

	var spawn_pos = player.global_position + Vector2(SPAWN_OFFSET_X, SPAWN_OFFSET_Y)

	get_parent().global_position = spawn_pos

	path_follow.progress = 0.0

	show()
	is_active = true
	is_paused = false
	already_attacked = false
	anim.play("flying")
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if !is_active:
		return

	if !is_paused:
		path_follow.progress += speed * delta
		global_position = path_follow.global_position

		if path_follow.progress_ratio >= 0.99 and not already_attacked:
			already_attacked = true
			_attack()

	if !is_paused and path_follow.progress_ratio <= 0.01 and already_attacked:
		_on_path_loop_restart()


func _attack() -> void:
	path_follow.set_process(false)
	is_paused = true
	

	var saved_progress = path_follow.progress
	path_follow.progress = saved_progress

	anim.play("attack")

	var fb = FIREBALL.instantiate()
	fb.global_position = fireball_spawn_point.global_position

	var world = get_tree().current_scene
	var player = world.get_node_or_null("player")
	if player:
		fb.target_position = player.global_position

	get_tree().current_scene.add_child(fb)

	await anim.animation_finished

	path_follow.set_process(false)
	is_paused = false
	anim.play("flying")


func _on_path_loop_restart() -> void:
	var world = get_parent().get_parent().get_parent()
	world.toggle_camera_movement()
	_despawn_enemy()


func _despawn_enemy():
	is_active = false
	anim.stop()
	hide()
	set_physics_process(false)
	path_follow.progress = 0.0
	_start_spawn_timer()
