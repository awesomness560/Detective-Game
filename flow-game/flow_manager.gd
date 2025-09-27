extends Node

# Existing variables
var isDragging : bool = false
var tempConnectionArray : Array[FlowCell]
var currentlyHoveredCell : FlowCell
var permanentConnections : Dictionary = {}
var allCells : Array[FlowCell] = []

# New puzzle progression variables
var colorOrder : Array[FlowCell.COLORS] = [FlowCell.COLORS.PURPLE, FlowCell.COLORS.RED, FlowCell.COLORS.YELLOW, FlowCell.COLORS.BLUE] # Define your color sequence here
var currentColorIndex : int = 0
var originCellsByColor : Dictionary = {} # Key: COLORS, Value: Array[FlowCell]

# Signal for puzzle completion
signal puzzle_completed(color_index: int)

func _ready():
	# Find and categorize all origin cells
	call_deferred("setup_puzzle_progression")

func setup_puzzle_progression():
	# Wait a frame to ensure all cells are registered
	await get_tree().process_frame
	
	# Find all origin cells and categorize them by color
	for cell in allCells:
		if cell.cellType == FlowCell.CELL_TYPE.ORIGIN:
			if not originCellsByColor.has(cell.cellColor):
				originCellsByColor[cell.cellColor] = []
			originCellsByColor[cell.cellColor].append(cell)
	
	# Hide all origins except the first color
	update_visible_origins()

func update_visible_origins():
	# First, identify which cells need to become new origins
	var newOriginPositions : Array[Vector2] = []
	if currentColorIndex < colorOrder.size():
		var currentColor = colorOrder[currentColorIndex]
		if originCellsByColor.has(currentColor):
			for cell in originCellsByColor[currentColor]:
				newOriginPositions.append(cell.cellPosition)

	# Check for conflicts: find connections that pass through new origin positions
	var connectionsToReset : Array[FlowCell.COLORS] = []
	for color in permanentConnections.keys():
		var connection = permanentConnections[color]
		var hasConflict = false
		
		for cell in connection:
			# Only check middle cells (not the origin endpoints)
			if cell.cellType == FlowCell.CELL_TYPE.EMPTY and cell.cellPosition in newOriginPositions:
				hasConflict = true
				print("Conflict found: connection of color ", color, " passes through new origin position ", cell.cellPosition)
				break
		
		if hasConflict and color not in connectionsToReset:
			connectionsToReset.append(color)

	# Reset conflicting connections
	for color in connectionsToReset:
		print("Resetting connection of color ", color, " due to conflict with new origins")
		resetConnectionByColor(color)

	# Now place the new origins
	if currentColorIndex < colorOrder.size():
		var currentColor = colorOrder[currentColorIndex]
		if originCellsByColor.has(currentColor):
			for cell in originCellsByColor[currentColor]:
				# Convert to origin
				cell.cellType = FlowCell.CELL_TYPE.ORIGIN
				cell.cellColor = currentColor
				cell.isPermanentConnection = false
				cell.permanentConnectionColor = FlowCell.COLORS.BLACK
				cell.resetHighlight()

	# Handle visibility for all colors
	for color in originCellsByColor.keys():
		var colorIndex = colorOrder.find(color)
		
		for cell in originCellsByColor[color]:
			if colorIndex > currentColorIndex:
				# This color hasn't been unlocked yet - hide it as empty cell
				cell.cellType = FlowCell.CELL_TYPE.EMPTY
				cell.cellColor = FlowCell.COLORS.BLACK
				cell.isPermanentConnection = false
				cell.permanentConnectionColor = FlowCell.COLORS.BLACK
				cell.resetHighlight()
			elif colorIndex < currentColorIndex:
				# This color was completed before - ensure it's shown as origin
				cell.cellType = FlowCell.CELL_TYPE.ORIGIN
				cell.cellColor = color
				
				# For completed colors that weren't reset, maintain their connection status
				if permanentConnections.has(color) and cell in permanentConnections[color]:
					cell.isPermanentConnection = true
					cell.permanentConnectionColor = color
					cell.highlightNode(cell.getActualColor())
				else:
					# This was a completed color but connection was reset - just show as origin
					cell.isPermanentConnection = false
					cell.permanentConnectionColor = FlowCell.COLORS.BLACK
					cell.resetHighlight()
			elif colorIndex == currentColorIndex:
				# This is the current color being unlocked - already handled above
				pass

func unlock_next_color():
	if currentColorIndex < colorOrder.size() - 1:
		currentColorIndex += 1
		print("Unlocking color index: ", currentColorIndex, " (", colorOrder[currentColorIndex], ")")
		update_visible_origins()
	else:
		print("All colors already unlocked!")

func check_puzzle_completion():
	if currentColorIndex >= colorOrder.size():
		return
		
	var currentColor = colorOrder[currentColorIndex]
	
	# Check if this color has a permanent connection
	if permanentConnections.has(currentColor):
		var connection = permanentConnections[currentColor]
		
		# Verify it connects both origins of this color
		if originCellsByColor.has(currentColor) and originCellsByColor[currentColor].size() == 2:
			var origins = originCellsByColor[currentColor]
			var firstOriginConnected = origins[0] in connection
			var secondOriginConnected = origins[1] in connection
			
			if firstOriginConnected and secondOriginConnected:
				print("Puzzle completed for color: ", currentColor)
				puzzle_completed.emit(currentColorIndex)
				return true
	
	return false

# Update existing functions
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
				# Check if this completed the current puzzle
				check_puzzle_completion()
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
		# Only change color for EMPTY cells, never for ORIGIN cells
		if cell.cellType == FlowCell.CELL_TYPE.EMPTY:
			cell.cellColor = connectionColor
		# ORIGIN cells keep their original color
		cell.isPermanentConnection = true
		cell.permanentConnectionColor = connectionColor
		cell.highlightNode(actualColor)  # Use the actual visual color
	
	print("Permanent connection created for color: ", connectionColor)

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

func resetConnectionByColor(color : FlowCell.COLORS):
	if not permanentConnections.has(color):
		return
		
	var connection = permanentConnections[color]
	
	# Reset all cells in this connection, but preserve origins
	for cell in connection:
		if cell.cellType == FlowCell.CELL_TYPE.EMPTY:
			# Reset empty cells back to default
			cell.cellColor = FlowCell.COLORS.BLACK
		elif cell.cellType == FlowCell.CELL_TYPE.ORIGIN:
			# Keep origin cells as origins, just remove their permanent connection status
			# Their color and type remain unchanged
			pass
		
		# Remove permanent connection status from all cells
		cell.isPermanentConnection = false
		cell.permanentConnectionColor = FlowCell.COLORS.BLACK
		cell.resetHighlight()
	
	# Remove from permanent connections
	permanentConnections.erase(color)
	print("Reset connection for color: ", color, " (origins preserved)")

func resetConnectionContainingCell(cell : FlowCell):
	# Find which permanent connection contains this cell
	for color in permanentConnections.keys():
		var connection = permanentConnections[color]
		if cell in connection:
			resetConnectionByColor(color)
			return

func resetTempConnectionArray():
	print("RESET")
	for cell in tempConnectionArray:
		if not cell.isPermanentConnection:
			cell.resetHighlight()
	tempConnectionArray.clear()
