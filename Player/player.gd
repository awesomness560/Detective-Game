extends Node3D
@export var speed : int = 7
@export var characterSprite : AnimatedSprite3D
@export var camera : Camera3D

# Character bounds
@export var character_min_x : float = -10.0
@export var character_max_x : float = 10.0

# Camera bounds
@export var camera_min_x : float = -15.0
@export var camera_max_x : float = 15.0

var isMoving : bool = false

func _process(delta: float) -> void:
	var new_x = global_position.x
	
	if Input.is_action_pressed("move_right") and Globals.canMove:
		new_x += speed * delta
		isMoving = true
		characterSprite.flip_h = false
	elif Input.is_action_pressed("move_left") and Globals.canMove:
		new_x -= speed * delta
		isMoving = true
		characterSprite.flip_h = true
	else:
		isMoving = false
	
	# Apply character bounds
	new_x = clamp(new_x, character_min_x, character_max_x)
	global_position.x = new_x
	
	# Apply camera bounds (independent of character position)
	if camera:
		var camera_x = clamp(camera.global_position.x, camera_min_x, camera_max_x)
		camera.global_position.x = camera_x
	
	if isMoving:
		characterSprite.play("default")
	else:
		characterSprite.stop()
