class_name StateMachine
extends Node

var _states: Dictionary = {}
var _transitions: Dictionary = {}  # { from_state: { event: to_state } }
var host: Player
var current_state: State
var current_state_name: String = ""
var is_running: bool = false

func register_state(state_name: String, state: State) -> void:
	_states[state_name] = state

func add_transition(from_state: String, event: String, to_state: String) -> void:
	if not _transitions.has(from_state):
		_transitions[from_state] = {}
	_transitions[from_state][event] = to_state

func change_state(new_name: String) -> void:
	if new_name == current_state_name:
		return
	if not _states.has(new_name):
		push_error("State not registered: ", new_name)
		return
	if current_state:
		current_state.exit(host)
	current_state = _states[new_name]
	current_state_name = new_name
	current_state.enter(host)

func process_event(event: String) -> void:
	if current_state_name.is_empty():
		return
	# Сначала ищем переход для текущего состояния
	if _transitions.has(current_state_name) and _transitions[current_state_name].has(event):
		change_state(_transitions[current_state_name][event])
		return
	# Ищем глобальный переход (из "*")
	if _transitions.has("*") and _transitions["*"].has(event):
		change_state(_transitions["*"][event])

func connect_input_signals(handler: InputHandler) -> void:
	handler.movement_started.connect(_on_movement_started)
	handler.movement_stopped.connect(_on_movement_stopped)
	handler.run_started.connect(_on_run_started)
	handler.run_stopped.connect(_on_run_stopped)

func _on_movement_started() -> void:
	# В зависимости от is_running генерируем разные события
	if is_running:
		process_event("start_run")
	else:
		process_event("start_walk")

func _on_movement_stopped() -> void:
	process_event("stop_movement")

func _on_run_started() -> void:
	is_running = true
	if current_state_name == "Walk":
		process_event("start_run")
	# Если мы в Idle, ничего не делаем — дождёмся начала движения

func _on_run_stopped() -> void:
	is_running = false
	if current_state_name == "Run":
		# Если движение ещё есть, переходим в Walk, иначе в Idle
		if Input.get_vector("left", "right", "up", "down").length() > 0:
			process_event("start_walk")
		else:
			process_event("stop_movement")

# physics_update остаётся без изменений
func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(host, delta)
