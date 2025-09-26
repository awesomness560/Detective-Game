extends Area3D


@export var unlock_message := "Shelf unlocked!"
@export var hintEnabled : bool = true
@export var hintColor : Color
@export var hintPulsingDuration : float = 1
@export var sprite3D : Sprite3D
@export var promptLabel : Label3D

var tween : Tween
var originalColor : Color

var _player_in := false : set = setPlayerIn
var _unlocked := false
var canBeFound = true : set = setCanBeFound

func _ready() -> void:
	originalColor = sprite3D.modulate
	canBeFound = true
	if hintEnabled == false:
		hintColor = originalColor
	#canBeFound = true
	area_entered.connect(onAreaEntered)
	area_exited.connect(onAreaExitied)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _player_in:
		_player_in = false
		canBeFound = false
		Globals.unlocked.emit(unlock_message)

func setCanBeFound(state : bool):
	if tween:
		tween.kill()
	
	if state:
		tween = create_tween()
		tween.tween_property(sprite3D, "modulate", hintColor, hintPulsingDuration)
		tween.tween_property(sprite3D, "modulate", originalColor, hintPulsingDuration)
		tween.set_loops()
		sprite3D.shaded = false
	else:
		sprite3D.shaded = true
		sprite3D.modulate = originalColor
	
	canBeFound = state

func setPlayerIn(state : bool):
	promptLabel.visible = state
	if state:
		if tween:
			tween.pause()
		sprite3D.modulate = hintColor
	else:
		if tween:
			tween.play()
	
	_player_in = state

func onAreaEntered(area : Area3D):
	if area.is_in_group("player") and canBeFound:
		_player_in = true

func onAreaExitied(area : Area3D):
	if area.is_in_group("player") and canBeFound:
		_player_in = false
