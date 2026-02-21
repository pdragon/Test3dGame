extends Node
class_name AnimationController

var animation_tree: AnimationTree
var animation_player: AnimationPlayer
var playback: AnimationNodeStateMachinePlayback

signal jump_land_finished

func init(anim_tree: AnimationTree, anim_player: AnimationPlayer) -> void:
	animation_tree = anim_tree
	animation_player = anim_player
	if animation_player and not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)
	# Даём время дереву инициализироваться (можно сразу, но лучше после ready)
	# Используем call_deferred, чтобы гарантировать, что дерево готово
	call_deferred("_setup_playback")

func _setup_playback():
	if animation_tree:
		playback = animation_tree.get("parameters/playback")
		#print("playback obtained: ", playback)

func _ready():
	animation_tree = get_parent().get_node('AnimationTree')
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
	#if animation_tree:
		#playback = animation_tree.get("parameters/playback")
		#print(playback)

func play_idle():
	if playback:
		#print("play_idle, current node: ", playback.get_current_node())
		playback.travel("Idle")
		await get_tree().process_frame
		#print("after travel, current node: ", playback.get_current_node())
	#print("play_idle, animation_tree = ", animation_tree)
	if animation_tree:
		var _playback = animation_tree.get("parameters/playback")
		print("playback = ", _playback)
		if _playback:
			_playback.travel("Idle")
		else:
			print("playback is null")
	else:
		print("animation_tree is null")
	if playback:
		playback.travel("Idle")

func play_walk():
	if playback and (owner as Player).is_on_floor():
		playback.travel("Walk")

func play_run():
	if playback:
		#print("play_run, current node: ", playback.get_current_node())
		playback.travel("Run")
		# Проверим, что за анимация проигрывается
		#var anim_node = animation_tree.tree_root.get_node("Run")  # если root - StateMachine
		#if anim_node and anim_node.has_method("get_animation"):
			#print("Run animation loop mode: ", anim_node.loop_mode)

func play_jump_start():
	if playback:
		playback.travel("JumpStart")

func play_jump_idle():
	if playback:
		playback.travel("JumpIdle")

func play_jump_land():
	if playback:
		playback.travel("JumpLand")
		
func _on_animation_finished(anim_name: StringName):
	print("Animation finished: ", anim_name)  # отладка
	if anim_name == "full/jump_Land":  # укажите точное имя анимации
		jump_land_finished.emit()
