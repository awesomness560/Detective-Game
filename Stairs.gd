extends Area3D
# Godot 4.5 - Stairs with auto-teleport, fade, sounds, and NPC support

@export var target_location: NodePath         # Drag a Marker/Spot where player spawns
@export var fade_rect: NodePath               # Drag UI/ScreenFade (ColorRect)
@export var stairs_duration: float = 2.5      # Fallback wait if stairs sound not available
@export var npc_follow_distance: float = 2.0  # NPC appears this far behind player on teleport

var _busy: bool = false

@onready var _stairs_sfx: AudioStreamPlayer3D = $StairsSFX

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not _busy:
		_start_transition()


func _start_transition() -> void:
	_busy = true

	# 1. Hide player sprite & pause player
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var sprite := player.get_node_or_null("Sprite3D")
		if sprite and sprite is Sprite3D:
			sprite.visible = false
		player.set_process(false)
		player.set_physics_process(false)

	# Hide NPC sprite too
	var npc := get_tree().get_first_node_in_group("npc")
	if npc:
		var npc_sprite := npc.get_node_or_null("Sprite3D")
		if npc_sprite and npc_sprite is Sprite3D:
			npc_sprite.visible = false

	# 2. Fade to black
	var fade := get_node_or_null(fade_rect)
	if fade:
		var t1 := create_tween()
		t1.tween_property(fade, "color:a", 1.0, 0.7)
		await t1.finished

	# 3. Play stairs sound
	_stairs_sfx.play()
	var wait_time := stairs_duration
	if _stairs_sfx.stream:
		wait_time = _stairs_sfx.stream.get_length()
	await get_tree().create_timer(wait_time).timeout

	# 4. Teleport player & NPC
	_teleport_entities()

	# 5. Fade back in
	if fade:
		var t2 := create_tween()
		t2.tween_property(fade, "color:a", 0.0, 0.7)
		await t2.finished

	_busy = false


func _teleport_entities() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var npc := get_tree().get_first_node_in_group("npc")
	var marker := get_node_or_null(target_location)
	if not player or not marker:
		return

	# Teleport player
	player.global_position = marker.global_position

	# Show player sprite again
	var sprite := player.get_node_or_null("Sprite3D")
	if sprite and sprite is Sprite3D:
		sprite.visible = true
	player.set_process(true)
	player.set_physics_process(true)

	# Teleport NPC just behind player
	if npc:
		var npc_pos = player.global_position + Vector3(-npc_follow_distance, 0, 0)
		npc.global_position = npc_pos

		var npc_sprite := npc.get_node_or_null("Sprite3D")
		if npc_sprite and npc_sprite is Sprite3D:
			npc_sprite.visible = true
