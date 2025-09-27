extends Area3D
# Door with teleport, fade, and sounds (works with Node3D player setup)

@export var target_location: NodePath      # Drag a RoomXSpot (Node3D) here
@export var fade_rect: NodePath            # Drag UI/ScreenFade (ColorRect) here
@export var stairs_duration: float = 2.5   # Default wait time if stairs sound length not available

var _player_in: bool = false
var _busy: bool = false  # prevents re-triggering

@onready var _prompt: Label3D = $PromptLabel
@onready var _door_sfx: AudioStreamPlayer3D = $DoorSFX
@onready var _stairs_sfx: AudioStreamPlayer3D = $StairsSFX

func _ready() -> void:
	_prompt.visible = false
	monitoring = true
	monitorable = true
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player") and not _busy:
		_player_in = true
		_prompt.visible = true
		print("Player entered door area")

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		_player_in = false
		_prompt.visible = false
		print("Player left door area")

func _unhandled_input(event: InputEvent) -> void:
	if _player_in and not _busy and event.is_action_pressed("interact"):
		_start_transition()

func _start_transition() -> void:
	_busy = true
	_prompt.visible = false

	# 1. Play door open sound
	_door_sfx.play()

	# 2. Hide player's Sprite3D
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var sprite := player.get_node_or_null("Sprite3D")
		if sprite and sprite is Sprite3D:
			sprite.visible = false
		player.set_process(false)
		player.set_physics_process(false)

	# 3. Fade to black
	var fade := get_node_or_null(fade_rect)
	if fade:
		var t1 := create_tween()
		t1.tween_property(fade, "color:a", 1.0, 0.7)
		await t1.finished

	# 4. Play stairs sound while black
	_stairs_sfx.play()
	var wait_time := stairs_duration
	if _stairs_sfx.stream:
		wait_time = _stairs_sfx.stream.get_length()
	await get_tree().create_timer(wait_time).timeout

	# 5. Teleport player
	_teleport_player()

	# 6. Fade back in
	if fade:
		var t2 := create_tween()
		t2.tween_property(fade, "color:a", 0.0, 0.7)
		await t2.finished

	_busy = false

func _teleport_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var marker := get_node_or_null(target_location)
	if not player or not marker:
		return

	# Move the player
	player.global_position = marker.global_position

	# Show Sprite3D again
	var sprite := player.get_node_or_null("Sprite3D")
	if sprite and sprite is Sprite3D:
		sprite.visible = true

	# Reactivate scripts
	player.set_process(true)
	player.set_physics_process(true)
