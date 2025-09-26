extends CanvasLayer
class_name FlowGame

@export var gridContainer : GridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var col : int = 0  # x-coordinate
	var row : int = 0  # y-coordinate
	
	for child in gridContainer.get_children():
		if child is FlowCell:
			child.cellPosition = Vector2(col, row)
			FlowManager.registerCell(child)  # Register the cell with FlowManager
		
		col += 1
		if col >= gridContainer.columns:
			col = 0
			row += 1
