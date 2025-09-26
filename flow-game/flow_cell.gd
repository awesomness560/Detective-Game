extends Control
class_name FlowCell

enum CELL_TYPE {
	EMPTY, ##Default, flows can go through this cell
	ORIGIN, ##Needs to be selected to make this a origin node (a node which is the start/end of a color)
}

enum COLORS {
	BLACK,
	BLUE,
	GREEN
}

@export var colorRect : ColorRect
##The type of cell this is
@export var cellType : CELL_TYPE
@export var cellColor : COLORS

var cellPosition : Vector2

##For when we want this cell to be highlighted
##with a custom color, aka, not be highlighted
##when hovering over it (there is already a color here)
var isHighlighted : bool = false

# New variables for permanent connections
var isPermanentConnection : bool = false
var permanentConnectionColor : COLORS = COLORS.BLACK

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	colorRect.color = getActualColor()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func handleResetInput():
	# Only allow reset if this cell is part of a permanent connection
	if isPermanentConnection:
		FlowManager.resetConnectionContainingCell(self)

func highlightNode(color : Color):
	isHighlighted = true
	colorRect.color = color

func resetHighlight():
	colorRect.color = getActualColor()
	isHighlighted = false

func _on_color_rect_mouse_entered() -> void:
	FlowManager.mouseEnteredCell(self)
	FlowManager.currentlyHoveredCell = self
	if isHighlighted or cellType == CELL_TYPE.ORIGIN or isPermanentConnection:
		return
	colorRect.color = Color.RED

func _on_color_rect_mouse_exited() -> void:
	if isHighlighted or cellType == CELL_TYPE.ORIGIN or isPermanentConnection:
		return
	colorRect.color = getActualColor()

func getActualColor() -> Color:
	match cellColor:
		COLORS.BLACK:
			return Color.BLACK
		COLORS.BLUE:
			return Color.AQUA
		COLORS.GREEN:
			return Color.GREEN
	return Color.PURPLE
