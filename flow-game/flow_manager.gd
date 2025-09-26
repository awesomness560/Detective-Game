extends Node

var isDragging : bool = false

var tempConnectionArray : Array[FlowCell]
var currentlyHoveredCell : FlowCell

# Dictionary to store permanent connections by color
# Key: COLORS enum value, Value: Array[FlowCell]
var permanentConnections : Dictionary = {}

var allCells : Array[FlowCell] = []

func registerCell(cell : FlowCell):
	allCells.append(cell)

func getAllCells() -> Array[FlowCell]:
	return allCells

func mouseEnteredCell(cell : FlowCell):
	var existingCellIndex : int = tempConnectionArray.find(cell)
	if isDragging:
		if existingCellIndex == -1:
			# Only check adjacency to the last cell in the path, not the whole path validity
			if tempConnectionArray.size() > 0:
				var lastCell = tempConnectionArray[-1]
				var distance = (cell.cellPosition - lastCell.cellPosition).abs()
				
				# Check if this cell is adjacent to the last cell
				if not ((distance.x == 1 and distance.y == 0) or (distance.x == 0 and distance.y == 1)):
					print("Cell not adjacent to last cell in path")
					return
				
				# Check if this cell is available (empty or matching origin)
				if cell.cellType == FlowCell.CELL_TYPE.EMPTY:
					# Check if it's occupied by a different permanent connection
					if cell.isPermanentConnection and cell.permanentConnectionColor != tempConnectionArray[0].cellColor:
						print("Cell occupied by different connection")
						return
				elif cell.cellType == FlowCell.CELL_TYPE.ORIGIN:
					# Can only connect to origin of same color
					if cell.cellColor != tempConnectionArray[0].cellColor:
						print("Cannot connect to origin of different color")
						return
				else:
					print("Cannot connect to this cell type")
					return
			
			# Add the cell and highlight it with the origin's color
			tempConnectionArray.append(cell)
			var originColor = tempConnectionArray[0].getActualColor()
			cell.highlightNode(originColor)
		else:
			resetTempConnectionArray()
			isDragging = false

func _input(event: InputEvent) -> void:
	if not currentlyHoveredCell:
		return
		
	# Handle reset connection input
	if event.is_action_pressed("reset_connection"):
		currentlyHoveredCell.handleResetInput()
		return
		
	if event.is_action_released("drag"):
		if isDragging and tempConnectionArray.size() > 0:
			# Check if we can auto-complete the connection
			var autoCompleted = tryAutoCompleteConnection()
			
			if autoCompleted or checkTempConnections():
				print("Valid connection completed!")
				finalizeTempConnection()
			else:
				print("Incomplete connection - resetting")
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
	
	# Use the color of the origin cell (first cell in the array)
	var originColor = tempConnectionArray[0].getActualColor()
	cell.highlightNode(originColor)

func finalizeTempConnection():
	if tempConnectionArray.size() < 2:
		return
		
	var connectionColor = tempConnectionArray[0].cellColor
	var actualColor = tempConnectionArray[0].getActualColor()
	
	# Remove any existing connection of this color first
	if permanentConnections.has(connectionColor):
		resetConnectionByColor(connectionColor)
	
	# Store the permanent connection
	permanentConnections[connectionColor] = tempConnectionArray.duplicate()
	
	# Set all cells in the connection to the permanent color and mark them
	for cell in tempConnectionArray:
		if cell.cellType == FlowCell.CELL_TYPE.EMPTY:
			cell.cellColor = connectionColor
		cell.isPermanentConnection = true
		cell.permanentConnectionColor = connectionColor
		cell.highlightNode(actualColor)  # Use the actual visual color
	
	print("Permanent connection created for color: ", connectionColor)

func resetConnectionByColor(color : FlowCell.COLORS):
	if not permanentConnections.has(color):
		return
		
	var connection = permanentConnections[color]
	
	# Reset all cells in this connection
	for cell in connection:
		if cell.cellType == FlowCell.CELL_TYPE.EMPTY:
			cell.cellColor = FlowCell.COLORS.BLACK  # Reset to default
		cell.isPermanentConnection = false
		cell.permanentConnectionColor = FlowCell.COLORS.BLACK
		cell.resetHighlight()
	
	# Remove from permanent connections
	permanentConnections.erase(color)
	print("Reset connection for color: ", color)

func resetConnectionContainingCell(cell : FlowCell):
	# Find which permanent connection contains this cell
	for color in permanentConnections.keys():
		var connection = permanentConnections[color]
		if cell in connection:
			resetConnectionByColor(color)
			return

func checkTempConnections() -> bool:
	print("Checking final connection, array size: ", tempConnectionArray.size())
	
	# Need at least 2 cells to form a connection
	if tempConnectionArray.size() < 2:
		print("Not enough cells")
		return false
	
	# First cell must be an ORIGIN
	if tempConnectionArray[0].cellType != FlowCell.CELL_TYPE.ORIGIN:
		print("First cell is not ORIGIN")
		return false
	
	# Last cell must be an ORIGIN of the same color for a valid completion
	var lastCell = tempConnectionArray[-1]
	if lastCell.cellType == FlowCell.CELL_TYPE.ORIGIN:
		var sameColor = lastCell.cellColor == tempConnectionArray[0].cellColor
		print("Ending on ORIGIN, same color: ", sameColor)
		return sameColor
	else:
		print("Connection must end on an ORIGIN of the same color")
		return false
		
func tryAutoCompleteConnection() -> bool:
	if tempConnectionArray.size() < 2:
		return false
	
	var lastCell = tempConnectionArray[-1]
	var originColor = tempConnectionArray[0].cellColor
	
	# If we're already ending on a matching origin, no need to auto-complete
	if lastCell.cellType == FlowCell.CELL_TYPE.ORIGIN and lastCell.cellColor == originColor:
		return true
	
	# Get all adjacent positions to the last cell
	var adjacentPositions = [
		lastCell.cellPosition + Vector2(1, 0),  # Right
		lastCell.cellPosition + Vector2(-1, 0), # Left
		lastCell.cellPosition + Vector2(0, 1),  # Down
		lastCell.cellPosition + Vector2(0, -1)  # Up
	]
	
	# Find all cells and check if any adjacent cell is a matching origin
	var allCells = getAllCells() # You'll need to implement this helper function
	
	for cell in allCells:
		if cell.cellPosition in adjacentPositions:
			# Check if this is a matching origin that we can connect to
			if cell.cellType == FlowCell.CELL_TYPE.ORIGIN and cell.cellColor == originColor:
				# Make sure it's not already in our connection path (avoid connecting to starting origin if path is too short)
				if cell != tempConnectionArray[0] or tempConnectionArray.size() > 2:
					print("Auto-completing connection to origin at: ", cell.cellPosition)
					tempConnectionArray.append(cell)
					var originActualColor = tempConnectionArray[0].getActualColor()
					cell.highlightNode(originActualColor)
					return true
	
	return false

func resetTempConnectionArray():
	print("RESET")
	for cell in tempConnectionArray:
		if not cell.isPermanentConnection:
			cell.resetHighlight()
	tempConnectionArray.clear()
