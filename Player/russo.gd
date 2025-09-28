extends Node3D
class_name Russo

@export var russoSprite : AnimatedSprite3D
@export var follow_distance : float = 2.0
@export var stop_distance : float = 0.5
@export var move_speed : float = 3.0

var player : Node3D
var is_clue_time : bool = false
var isMoving : bool = false
var isFinal : bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	Globals.clueTime.connect(clueTime)
	Globals.final.connect(final)

func final():
	isFinal = true
	russoSprite.play("idle_normal")

func _process(delta: float) -> void:
	if not player or isFinal:
		return
	
	var distance_x = abs(player.global_position.x - global_position.x)
	
	if distance_x > follow_distance or (isMoving and distance_x > stop_distance):
		if player.global_position.x > global_position.x:
			global_position.x += move_speed * delta
			russoSprite.flip_h = false
		else:
			global_position.x -= move_speed * delta
			russoSprite.flip_h = true
		isMoving = true
	else:
		isMoving = false
	
	if isMoving:
		if russoSprite.animation != "walk":
			russoSprite.play("walk")
	else:
		var idle_anim = "idle_clue" if is_clue_time else "idle_normal"
		if russoSprite.animation != idle_anim:
			russoSprite.play(idle_anim)

func clueTime(state: bool):
	is_clue_time = state
