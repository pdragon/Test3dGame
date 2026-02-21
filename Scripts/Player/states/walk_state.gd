class_name WalkState
extends State

func enter(host: Node) -> void:
	var player = host as Player
	if player and player.animation_controller:
		player.animation_controller.play_walk()

func physics_update(host: Node, delta: float) -> void:
	var player = host as Player
	if not player:
		return
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction.length() > 0 and player.is_on_floor():
		if player.model_node:
			var target_angle = atan2(direction.x, direction.z)
			player.model_node.rotation.y = target_angle
		var target_vel = direction * player.walk_speed
		player.velocity.x = move_toward(player.velocity.x, target_vel.x, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, target_vel.z, player.acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta)
