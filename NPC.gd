extends Node3D
@export var follow_distance: float = 2.0       
@export var base_speed: float = 3.5            
@export var catchup_multiplier: float = 1.25   
@export var max_speed: float = 7.0          
@export var ground_y: float = 0.0               
@export var debug_enabled: bool = true
@export var debug_every_sec: float = 1.0
@onready var debug_label: Label3D = get_node_or_null("DebugLabel")
var player: Node3D = null
var _log_timer: float = 0.0
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		push_warning("NPC cannot find a node in group 'player'!")
	if debug_enabled:
		_dlog("--- NPC READY ---")
		_dlog("Has player? %s" % (player != null))
		if debug_label:
			debug_label.visible = true
func _physics_process(delta: float) -> void:
	_log_timer += delta
	var do_log := debug_enabled and (_log_timer >= debug_every_sec)
	if do_log:
		_log_timer = 0.0

	if not player:
		if do_log: _dlog("NO PLAYER in group 'player'.")
		_set_overlay("NO PLAYER")
		return
	var npc_x: float = global_position.x
	var player_x: float = player.global_position.x

	var to_player: float = player_x - npc_x
	var abs_dist: float = abs(to_player)

	if abs_dist > follow_distance:
		var target_x: float = player_x - sign(to_player) * follow_distance
		var delta_x: float = target_x - npc_x
		var move_speed: float = min(base_speed + abs(delta_x) * catchup_multiplier, max_speed)

		if abs(delta_x) > 0.01: 
			npc_x += sign(delta_x) * move_speed * delta
		global_position = Vector3(npc_x, ground_y, global_position.z)
		if do_log:
			_dlog("MOVING: dist=%.2f | delta_x=%.2f" % [abs_dist, delta_x])
			_set_overlay("MOVE d=%.2f" % abs_dist)
	else:
		if do_log:
			_dlog("HOLD: dist=%.2f (≤ %.2f). Staying still." % [abs_dist, follow_distance])
			_set_overlay("HOLD d=%.2f" % abs_dist)
func _set_overlay(text: String) -> void:
	if debug_label:
		debug_label.text = text

func _dlog(msg: String) -> void:
	print("[NPC] " + msg)
