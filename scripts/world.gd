extends Node2D

@onready var camera := $camera as Camera2D
@onready var player: CharacterBody2D = $player
@onready var right_wall: StaticBody2D = $right_wall

@export var camera_speed := 50.0
@export var push_strength := 100.0 

var camera_active := true

func _process(delta: float) -> void:
	if camera_active:
		camera.global_position.x += camera_speed * delta
	
	# Camera follows player Y position
	camera.global_position.y = lerp(
		camera.global_position.y,
		player.global_position.y,
		5.0 * delta
	)
	
	var cam_center = camera.get_screen_center_position()

	var left_edge = cam_center.x - 240
	var right_edge = cam_center.x 
	if player.global_position.x < left_edge:
		player.take_damage_from_camera_movement()
		
	right_wall.global_position.x = right_edge
	
func toggle_camera_movement():
	camera_active = true if !camera_active else false
	
