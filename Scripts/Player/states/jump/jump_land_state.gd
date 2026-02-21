class_name JumpLandState
extends State

var _timer := 0.0
var _anim_length := 0.3  # запасное значение, если не удастся получить длину

func enter(host: Node) -> void:
	var player = host as Player
	if not player:
		return
	# Получаем точную длину анимации из AnimationPlayer
	var anim_name = "full/Jump_Land"  # Убедитесь, что имя совпадает с play_jump_land()
	var anim = player.animation_controller.animation_player.get_animation(anim_name)
	if anim:
		_anim_length = anim.length
		print("JumpLand animation length: ", _anim_length)  # отладка
	else:
		print("Warning: animation not found, using fallback length")
	_timer = 0.0
	player.animation_controller.play_jump_land()

func physics_update(host: Node, delta: float) -> void:
	_timer += delta
	var player = host as Player
	if not player:
		return
	if _timer >= _anim_length:
		# Анимация завершилась
		var moving = Input.get_vector("left", "right", "up", "down").length() > 0
		var is_running = Input.is_action_pressed("run")
		var target = "Idle"
		if moving:
			target = "Run" if is_running else "Walk"
		player.state_machine.change_state(target)
