extends CharacterBody3D
class_name Player

const JUMP_VELOCITY = 4.5

@export var walk_speed := 5.0
@export var run_speed := 8.0
@export var acceleration := 30.0
@export var friction := 30.0#8.0
@export var model_node: Node3D

var input_handler: InputHandler
var animation_controller: AnimationController
var state_machine: StateMachine
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Создание узлов (как обсуждали ранее)
	input_handler = InputHandler.new()
	add_child(input_handler)
	
	animation_controller = $AnimationController
	#add_child(animation_controller)
	
	# Создание AnimationTree
	var anim_tree = $AnimationTree #AnimationTree.new()
	
	# Указываем AnimationPlayer
	anim_tree.anim_player = NodePath("../Skeleton3D/idle-animations-body/AnimationPlayer2")

	# Создаём корневую StateMachine
	var root = AnimationNodeStateMachine.new()
	anim_tree.tree_root = root
	
	# --- Добавляем узлы анимаций ---
	var idle_node = AnimationNodeAnimation.new()
	idle_node.animation = "full/Idle" 
	root.add_node("Idle", idle_node, Vector2(200, 0))

	var walk_node = AnimationNodeAnimation.new()
	walk_node.animation = "full/Walk"
	root.add_node("Walk", walk_node, Vector2(400, 0))

	var run_node = AnimationNodeAnimation.new()
	run_node.animation = "full/Run Anime"
	run_node.loop_mode = true
	root.add_node("Run", run_node, Vector2(600, 0))
	
	# Создание узлов для прыжка
	var jump_start_node = AnimationNodeAnimation.new()
	jump_start_node.animation = "full/Jump_Start"  # точное имя анимации в AnimationPlayer
	root.add_node("JumpStart", jump_start_node, Vector2(200, 100))

	var jump_idle_node = AnimationNodeAnimation.new()
	jump_idle_node.animation = "full/Jump"
	root.add_node("JumpIdle", jump_idle_node, Vector2(400, 100))

	var jump_land_node = AnimationNodeAnimation.new()
	jump_land_node.animation = "full/Jump_Land"
	root.add_node("JumpLand", jump_land_node, Vector2(600, 100))

	# --- Соединяем Start с Idle ---
	var trans_start = AnimationNodeStateMachineTransition.new()
	root.add_transition("Start", "Idle", trans_start)

	# Активируем дерево
	anim_tree.active = true

	# Передаём ссылку в AnimationController
	animation_controller.animation_tree = anim_tree
	
	state_machine = StateMachine.new()
	state_machine.host = self
	add_child(state_machine)
	animation_controller.init(anim_tree, get_node('Skeleton3D/idle-animations-body/AnimationPlayer2'))
	
	state_machine.host = self
	state_machine.connect_input_signals(input_handler)
	setup_state_machine()
	#print("Переходы из Walk: ", root.get_transitions_from("Walk"))
	#state_machine.change_state(&"Idle")
	state_machine.change_state("Idle")
	
	# Подключаем сигнал прыжка
	input_handler.jump_pressed.connect(_on_jump_pressed)

func setup_state_machine():
	 # Регистрация состояний
	state_machine.register_state("Idle", IdleState.new())
	state_machine.register_state("Walk", WalkState.new())
	state_machine.register_state("Run", RunState.new())
	state_machine.register_state("JumpStart", JumpStartState.new())
	state_machine.register_state("JumpIdle", JumpIdleState.new())
	state_machine.register_state("JumpLand", JumpLandState.new())

	# Переходы для движения
	state_machine.add_transition("Idle", "start_walk", "Walk")
	state_machine.add_transition("Idle", "start_run", "Run")
	state_machine.add_transition("Walk", "start_run", "Run")
	state_machine.add_transition("Run", "start_walk", "Walk")  # если нужно
	state_machine.add_transition("Walk", "stop_movement", "Idle")
	state_machine.add_transition("Run", "stop_movement", "Idle")
	state_machine.add_transition("JumpLand", "start_walk", "Walk")
	state_machine.add_transition("JumpLand", "start_run", "Run")

	# Переходы для прыжка (глобальный)
	state_machine.add_transition("*", "jump", "JumpStart")

func _on_jump_pressed():
	# Прыгать можно только с земли и не во время прыжка
	if is_on_floor() and state_machine.current_state_name not in ["JumpStart", "JumpIdle", "JumpLand"]:
		velocity.y = JUMP_VELOCITY
		state_machine.process_event("jump")
	else:
		# Отладка: почему не прыгает
		print("Can't jump: is_on_floor=", is_on_floor(), " state=", state_machine.current_state_name)

func _physics_process(delta):
	# Гравитация (применяется всегда, если не на полу)
	if not is_on_floor():
		velocity.y -= gravity * delta
		if position.y < -10.0:
			position = Vector3(0,0,0)

	# Обновление текущего состояния (физика движения)
	state_machine.physics_update(delta)
	move_and_slide()
