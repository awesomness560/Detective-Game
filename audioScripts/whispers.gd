extends AudioStreamPlayer

@export var timer : Timer

func _ready() -> void:
	timer.timeout.connect(onTimeout)
	Globals.convoFinished.connect(onPuzzleCompleted)

func onPuzzleCompleted(puzzle : int):
	if puzzle == 0:
		timer.start()

func onTimeout():
	play()
	setRandomTime()

func setRandomTime():
	var randomTime = randi_range(5, 15)
	timer.wait_time = randomTime
	timer.start()
