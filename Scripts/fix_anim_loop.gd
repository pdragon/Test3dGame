@tool
extends EditorScenePostImport

# Указываем, какие анимации должны быть зациклены.
# Можно использовать массив строк или частичные названия.
const LOOP_ANIMATIONS = ["Idle", "Walk", "Run"]

func _post_import(scene: Node) -> Node:
	print("--- Running post-import script: fix_anim_loop.gd ---")

	# Рекурсивно обходим всю сцену в поисках AnimationPlayer
	_process_node(scene)

	print("--- Post-import finished ---")
	return scene

func _process_node(node: Node) -> void:
	if node is AnimationPlayer:
		print("  Found AnimationPlayer: ", node.name)
		_set_animation_loops(node)

	# Обрабатываем всех детей
	for child in node.get_children():
		_process_node(child)

func _set_animation_loops(anim_player: AnimationPlayer) -> void:
	for anim_name in anim_player.get_animation_list():
		var anim = anim_player.get_animation(anim_name)
		# Проверяем, нужно ли зациклить эту анимацию по нашему списку
		if _should_loop(anim_name):
			# Устанавливаем режим линейного цикла (LOOP_LINEAR)
			# Другие варианты: Animation.LOOP_PINGPONG
			if anim.loop_mode != Animation.LOOP_LINEAR:
				anim.loop_mode = Animation.LOOP_LINEAR
				print("    Set LOOP_LINEAR for: ", anim_name)
			else:
				print("    Already looped: ", anim_name)
		else:
			print("    Skipped (non-loop): ", anim_name)

func _should_loop(anim_name: String) -> bool:
	for name_part in LOOP_ANIMATIONS:
		# Проверяем, содержится ли ключевое слово в имени анимации
		if name_part in anim_name:
			return true
	return false
