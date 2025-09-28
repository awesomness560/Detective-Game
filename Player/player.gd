extends Node3D

@export var speed : int = 7
@export var characterSprite : AnimatedSprite3D

var isMoving : bool = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_right") and Globals.canMove:
		global_position.x += speed * delta
		isMoving = true
		characterSprite.flip_h = false
	elif Input.is_action_pressed("move_left") and Globals.canMove:
		global_position.x -= speed * delta
		isMoving = true
		characterSprite.flip_h = true
	else:
		isMoving = false
	
	if isMoving:
		characterSprite.play("default")
	else:
		characterSprite.stop()
