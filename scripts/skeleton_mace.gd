extends CharacterBody2D

enum State { PATROL, CHASE, ATTACK }

const SPEED = 40.0
const ATTACK_RANGE = 50.0
const ATTACK_COOLDOWN = 3.0

@onready var wall_detector := $wall_detector as RayCast2D
@onready var anim: AnimatedSprite2D = $anim
@onready var attack_area = $anim/hitbox/collision as CollisionShape2D
@onready var collision: CollisionShape2D = $collision

var direction := -1
var current_state := State.PATROL
var target: Node = null
var can_attack = true
var is_dead = false

func _ready() -> void:
	if not anim.animation_finished.is_connected(_on_anim_animation_finished):
		anim.animation_finished.connect(_on_anim_animation_finished)

func _physics_process(_delta: float) -> void:	
	if is_dead:
		return
		
	match current_state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase()
		State.ATTACK:
			_attack()
		
func _patrol() -> void:
	anim.play("walk")
	_verify_wall_colision()
	
	anim.scale.x = direction  * -1 # we multiply because the sprite is inverted (right to left)
		
	velocity.x = direction * SPEED 

	move_and_slide()
	
func _chase() -> void:
	if not target:
		current_state = State.PATROL
		return
	
	anim.play("walk")
	
	direction = sign(target.global_position.x - global_position.x)
	wall_detector.scale.x = direction * -1
	velocity.x = direction * SPEED * 1.1
	anim.scale.x = direction * -1

	move_and_slide()
	
	if global_position.distance_to(target.global_position) < ATTACK_RANGE:
		current_state = State.ATTACK
	
func _attack() -> void:
	if !can_attack:
		current_state = State.PATROL
		return
		
	velocity = Vector2.ZERO
	anim.play("attack")
	
	if anim.frame == 5:
		attack_area.disabled = false
	else:
		attack_area.disabled = true
		
	
	move_and_slide()
		
func _verify_wall_colision() -> void:
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1


func _on_anim_animation_finished() -> void:
	if anim.animation == "die":
		queue_free()
	elif anim.animation == "attack":
		_start_attack_cooldown()
		
		if target:
			current_state = State.CHASE
		else:
			current_state = State.PATROL
			
func _start_attack_cooldown() -> void:
	can_attack = false
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true
	
func _on_player_detection_area_body_entered(body: Node2D) -> void:
	target = body
	current_state = State.CHASE

func _on_player_detection_area_body_exited(_body: Node2D) -> void:
	target = null
	if current_state != State.ATTACK:
		current_state = State.PATROL

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	collision.set_deferred("disabled", true)
	is_dead = true
	anim.play("die")
	velocity = Vector2.ZERO
	move_and_slide()
