# input_handler.gd
class_name InputHandler
extends Node

signal movement_started()
signal movement_stopped()
signal run_started()
signal run_stopped()
signal jump_pressed

var _last_move_dir = Vector2.ZERO
var _last_run = false

func _process(_delta):
	var move_dir = Input.get_vector("left", "right", "up", "down")
	var is_running = Input.is_action_pressed("run")
	var is_jumping = Input.is_action_pressed("jump")

	if move_dir.length() > 0 and _last_move_dir.length() == 0:
		movement_started.emit()
	elif move_dir.length() == 0 and _last_move_dir.length() > 0:
		movement_stopped.emit()

	if is_running and not _last_run:
		run_started.emit()
	elif not is_running and _last_run:
		run_stopped.emit()
		
	if is_jumping:
		jump_pressed.emit()

	_last_move_dir = move_dir
	_last_run = is_running

#func _input(event: InputEvent):
	#if event.is_action_pressed("jump"):
		#jump_pressed.emit()
