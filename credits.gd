extends CanvasLayer

@onready var credits: VBoxContainer = $Credits
@onready var texture_rect: TextureRect = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(credits, "global_position:y", -505.0, 20)
	
	await tween.finished
	
	texture_rect.show()
