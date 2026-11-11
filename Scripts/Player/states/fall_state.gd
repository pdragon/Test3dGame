class_name FallState
extends State

func enter(host: Node) -> void:
	var player = host as Player
	if player and player.animation_controller:
		player.animation_controller.play_fall()

func physics_update(host: Node, delta: float) -> void:
	var player = host as Player
	if not player:
		return

	# Управление в воздухе (ослабленное)
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction.length() > 0:
		if player.model_node:
			var target_angle = atan2(direction.x, direction.z)
			player.model_node.rotation.y = target_angle
		var target_vel = direction * player.walk_speed
		player.velocity.x = move_toward(player.velocity.x, target_vel.x, player.acceleration * delta * 0.5)
		player.velocity.z = move_toward(player.velocity.z, target_vel.z, player.acceleration * delta * 0.5)
	else:
		# Без ввода — гасим горизонтальную скорость, чтобы не «улетать» в пропасть
		player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta * 0.5)
		player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta * 0.5)


	# Приземлились — проигрываем анимацию приземления
	if player.is_on_floor():
		player.state_machine.change_state("JumpLand")
		return

	# Упали в пропасть
	if player.global_position.y < -20:
		player.global_position = Vector3.ZERO
		player.velocity = Vector3.ZERO
		player.state_machine.change_state("Idle")
