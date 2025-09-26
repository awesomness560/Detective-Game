extends Area3D
# Godot 4.5

@export var unlock_message := "Shelf unlocked!"

var _player_in := false
var _unlocked := false

@onready var _shelf := $ShelfSprite
@onready var _glow := $ShelfGlow
@onready var _prompt := $PromptLabel
@onready var _ui := get_tree().get_first_node_in_group("unlock_ui") as Control

func _ready() -> void:
	# Start gray
	_shelf.modulate = Color(0.25, 0.25, 0.25, 1.0)
	_glow.visible = false
	_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not _unlocked:
		_player_in = true
		_glow.visible = true
		_prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in = false
		_glow.visible = false
		_prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in and not _unlocked and event.is_action_pressed("interact"):
		_unlocked = true
		_shelf.modulate = Color(1, 1, 1, 1)  # restore full color
		_glow.visible = false
		_prompt.visible = false
		_notify(unlock_message)

func _notify(msg: String) -> void:
	if _ui and _ui.has_method("show_unlock"):
		_ui.call("show_unlock", msg)
