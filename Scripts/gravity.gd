extends CharacterBody3D

# Константы движения
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Гравитация (обычно берётся из настроек проекта)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Добавляем гравитацию
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Обработка ввода и движение...
	# ...

	move_and_slide()
