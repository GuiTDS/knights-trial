extends Node

class_name State

var player
var state_machine

# call when enters the state
func enter() -> void:
	set_process(false)
	set_physics_process(false)

# called when exits the state
func exit() -> void:
	set_process(false)
	set_physics_process(false)
	
# handle input events
func handle_input(event) -> void:
	pass

# normal update
func update(delta: float) -> void:
	pass

# physics update
func physics_update(delta: float) -> void:
	pass
