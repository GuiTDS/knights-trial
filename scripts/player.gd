extends CharacterBody2D

const SPEED = 120.0

@onready var state_machine: StateMachine = $state_machine
@onready var anim := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var attack_area := $anim/hitbox/collision as CollisionShape2D

## The current amount of life/health points of the player.
## When this value reaches 0, the player dies.
@export var max_health: int = 5 
## Horizontal force applied to the player when taking damage.
@export var knockback_force_x = 250
## Vertical force applied to the player when taking damage.
@export var knockback_force_y = -120

var health
var knockback: Vector2

signal stats_changed

func _ready() -> void:
	health = max_health
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
		knockback = Vector2(-knockback_force_x, knockback_force_y)
	else:
		knockback = Vector2(knockback_force_x, knockback_force_y)
	state_machine.change_state(state_machine.get_node("hurt_state"))
