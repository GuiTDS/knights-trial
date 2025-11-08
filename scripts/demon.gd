extends CharacterBody2D

const SPEED = 100.0
const PAUSE_TIME = 2.0
const RESPAWN_TIME = 10.0
const SPAWN_OFFSET_X = -300.0 # distance to the left of the player
const SPAWN_OFFSET_Y = -150.0 # height above the player

@onready var path_follow = $"../path2D/path_follow2D"
@onready var anim = $"../anim"

var is_paused = false
var reached_end = false
var is_active = false

func _ready() -> void:
	hide()
	set_physics_process(false)
	_start_spawn_timer()

func _start_spawn_timer() -> void:
	await get_tree().create_timer(RESPAWN_TIME).timeout
	_spawn_enemy_near_player()

## Spawns the enemy relative to the player's position.
## 
## This function locates the player node in the scene and positions the enemy 
## near the player based on the predefined spawn offset constants.
## It ensures the enemy becomes visible, resets its path movement, 
## and reactivates its physics and animation for proper behavior.
##
## Flow:
## 1. Gets the reference to the 'World' node by navigating up the scene tree.
## 2. Tries to find the 'player' node as a direct child of 'World'.
## 3. If the player is not found, the spawn timer restarts to retry later.
## 4. If found, calculates the new spawn position using SPAWN_OFFSET_X/Y.
## 5. Moves the enemy (parent node) to that position and resets its path.
## 6. Shows the enemy, re-enables physics, and plays the spawn animation.
func _spawn_enemy_near_player() -> void:
	var world = get_parent().get_parent().get_parent()

	var player = world.get_node_or_null("player")
	if player == null:
		print("Player não encontrado como filho direto de 'World'.")
		_start_spawn_timer()
		return

	var spawn_pos = player.global_position + Vector2(SPAWN_OFFSET_X, SPAWN_OFFSET_Y)

	get_parent().global_position = spawn_pos
	path_follow.progress_ratio = 0.0

	show()
	set_physics_process(true)
	is_active = true
	anim.play()
	print("Inimigo spawnado próximo ao player em: ", spawn_pos)

func _physics_process(delta: float) -> void:
	if !is_active or is_paused:
		return
	
	if path_follow.progress_ratio >= 1.0 - 0.005 and !reached_end:
		reached_end = true
		_on_reach_end()
	elif path_follow.progress_ratio <= 0.005 and reached_end:
		reached_end = false
		_on_reach_start()

func _on_reach_end():
	is_paused = true
	anim.pause()
	await get_tree().create_timer(PAUSE_TIME).timeout
	is_paused = false
	anim.play()

func _on_reach_start():
	_despawn_enemy()

func _despawn_enemy() -> void:
	is_active = false
	anim.stop()
	hide()
	set_physics_process(false)
	path_follow.progress_ratio = 0.0
	print("Inimigo completou o trajeto e despawnou.")
	_start_spawn_timer()
