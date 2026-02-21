class_name State
extends RefCounted

func enter(_host: Node) -> void:
	pass

func exit(_host: Node) -> void:
	pass

func handle_input(_host: Node, _event: InputEvent) -> void:
	pass

func update(_host: Node, _delta: float) -> void:
	pass

func physics_update(_host: Node, _delta: float) -> void:
	pass
