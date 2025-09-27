extends Node3D

@export var speed : float = 7.0
@export var stair_climb_speed : float = 3.0   # how fast to slide up stairs
@export var ground_y : float = 0.0            # floor height

var current_stair: Area3D = null              # reference to stair we are inside

func _process(delta: float) -> void:
	var move_vec = Vector3.ZERO

	# Basic movement on X/Z
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_forward"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_backward"):
		move_vec.z += 1

	# Normalize so diagonal isn’t faster
	if move_vec.length() > 0:
		move_vec = move_vec.normalized() * speed * delta

	# Apply horizontal movement
	global_position.x += move_vec.x
	global_position.z += move_vec.z

	# --- Handle stairs ---
	if current_stair:
		# Use the stair slope property to calculate Y
		var local_pos = current_stair.get_parent().to_local(global_position)
		var slope = current_stair.get_parent().get("slope")
		var target_y = local_pos.x * slope
		global_position.y = lerp(global_position.y, target_y, stair_climb_speed * delta)
	else:
		# Stay at ground level when no stairs
		global_position.y = lerp(global_position.y, ground_y, stair_climb_speed * delta)


# --- Signals from Area3D (stairs) ---
func _on_stair_area_area_entered(area: Area3D) -> void:
	# Player must have its own Area3D to detect overlaps
	if area.is_in_group("stairs"):
		current_stair = area

func _on_stair_area_area_exited(area: Area3D) -> void:
	if area == current_stair:
		current_stair = null
