extends Node

var isDragging : bool = false

var tempConnectionArray : Array[FlowCell]
var currentlyHoveredCell : FlowCell

func mouseEnteredCell(cell : FlowCell):
	var existingCellIndex : int = tempConnectionArray.find(cell)
	if isDragging:
		if existingCellIndex == -1:
			addCellToTempConnections(cell)
		else:
			resetTempConnectionArray()
			isDragging = false

func _input(event: InputEvent) -> void:
	if not currentlyHoveredCell:
		return
	if event.is_action_released("drag"):
		isDragging = false
		resetTempConnectionArray()
	if currentlyHoveredCell.cellType \
		!= currentlyHoveredCell.CELL_TYPE.ORIGIN:
			return
	if event.is_action_pressed("drag"):
		isDragging = true
		addCellToTempConnections(currentlyHoveredCell)

func addCellToTempConnections(cell : FlowCell):
	if not currentlyHoveredCell:
		return
	tempConnectionArray.append(cell)
	cell.highlightNode(Color.AQUA)

func resetTempConnectionArray():
	print("RESET")
	for cell in tempConnectionArray:
		cell.resetHighlight()
	tempConnectionArray.clear()
