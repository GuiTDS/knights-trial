extends Node
class_name StateMachine

@export var initial_state: NodePath = NodePath("")

var current_state: State = null
var states = {}

func _ready() -> void:
	await get_tree().process_frame 
	for child in get_children():
		if child is State:
			child.state_machine = self
			states[child.name] = child
			child.set_process(false)
			child.set_physics_process(false)
	
	if initial_state != NodePath(""):
		var init_node := get_node_or_null(initial_state)
		if init_node and init_node is State:
			change_state(init_node)
		else:
			push_error("StateMachine: invalid initial_state: %s" % initial_state)
	else:
		pass
		
func change_state(new_state: State) -> void:
	if not new_state:
		push_warning("StateMachine.change_state: new_state is null")
		return
	
	if current_state == new_state:
		return
	if current_state:
		current_state.exit()
		current_state.set_process(false)
		current_state.set_physics_process(false)
	
	current_state = new_state
	current_state.set_process(true)
	current_state.set_physics_process(true)
	current_state.enter()
	
	print("[StateMachine] changed to:", current_state.name)
	
func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
		
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
		
func change_state_by_name(state_name: String) -> void:
	if states.has(state_name):
		change_state(states[state_name])
	else:
		push_warning("StateMachine.change_state_by_name: state not found: %s" % state_name)
