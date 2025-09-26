extends Node3D

@export var speed : int = 7

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		global_position.x += speed * delta
	if Input.is_action_pressed("move_left"):
		global_position.x -= speed * delta
	if Input.is_action_pressed("move_forward"):
		global_position.z -= speed * delta
	if Input.is_action_pressed("move_backward"):
		global_position.z += speed * delta
