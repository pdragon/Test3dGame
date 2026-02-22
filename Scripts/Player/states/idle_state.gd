class_name IdleState
extends State

func enter(host: Node) -> void:
	var player = host as Player
	if player and player.animation_controller:
		player.animation_controller.play_idle()

func physics_update(host: Node, delta: float) -> void:
	var player = host as Player
	if not player:
		printerr("НЕ игрок пытается войти в состояние Idle!")
		return
	# Если не на земле и не в прыжке — падаем
	if not player.is_on_floor() and player.state_machine.current_state_name not in ["JumpStart", "JumpIdle"]:
		player.state_machine.change_state("Fall")
		return
		
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta)
