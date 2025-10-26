extends CharacterBody2D

const SPEED = 130.0
const X_COLLIDING_FORCE = 250

@onready var state_machine: StateMachine = $state_machine
@onready var anim := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var attack_area := $anim/hitbox/collision as CollisionShape2D

var player_life := 4 # 5 hearts
var knockback_vector := Vector2.ZERO
var knockback: Vector2

func _ready() -> void:
	velocity = Vector2.ZERO
	
	for s in state_machine.get_children():
		if s is State:
			s.player = self
			s.state_machine = state_machine

func _input(event: InputEvent) -> void:
	state_machine._input(event)
	
func _process(delta: float) -> void:
	state_machine._process(delta)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	state_machine._physics_process(delta)
	
	move_and_slide()

func follow_camera(camera): 
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
#
func _on_hurtbox_area_entered(area: Area2D) -> void:
	var attacker = area.get_parent() # enemy node reference
	if attacker.global_position.x > global_position.x:
		knockback = Vector2(-X_COLLIDING_FORCE, -120)
	else:
		knockback = Vector2(X_COLLIDING_FORCE, -120)
	state_machine.change_state(state_machine.get_node("hurt_state"))
