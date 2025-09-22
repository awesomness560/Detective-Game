extends CanvasLayer
class_name FlowGame

@export var gridContainer : GridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var row : int = 0
	var col : int = 0
	
	for child in gridContainer.get_children():
		if row >= gridContainer.columns:
			row = 0
			col += 1
		
		if child is FlowCell:
			child.cellPosition = Vector2(row, col)
		
		row += 1
