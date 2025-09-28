extends Node
@export var allLights : Array[Light3D]
@export var finalColor : Color
@export var minFlickerSpeed : float = 0.05   # Fastest flicker interval
@export var maxFlickerSpeed : float = 0.3    # Slowest flicker interval

var isFlickering : bool = false
var flickerTimers : Array[Timer] = []

func _ready():
	# Create individual timers for each light
	for light in allLights:
		var timer = Timer.new()
		timer.wait_time = randf_range(minFlickerSpeed, maxFlickerSpeed)
		timer.timeout.connect(_on_light_flicker.bind(light, timer))
		add_child(timer)
		flickerTimers.append(timer)
	Globals.convoFinished.connect(convoFinished)
	Globals.final.connect(onFinal)
	

func onFinal():
	for light in allLights:
		light.light_color = Color.RED

func convoFinished(theOne : int):
	if theOne == 3:
		startLightsFlicker()

func startLightsFlicker():
	if isFlickering:
		return
	
	isFlickering = true
	
	# Start all individual flicker timers
	for i in range(allLights.size()):
		if i < flickerTimers.size():
			flickerTimers[i].wait_time = randf_range(minFlickerSpeed, maxFlickerSpeed)
			flickerTimers[i].start()

func _on_light_flicker(light: Light3D, timer: Timer):
	if not isFlickering:
		return
	
	# Randomly toggle light on/off
	light.visible = not light.visible
	
	# Randomize next flicker timing for more erratic behavior
	timer.wait_time = randf_range(minFlickerSpeed, maxFlickerSpeed)
	timer.start()

func stopLightsFlicker():
	isFlickering = false
	
	# Stop all flicker timers
	for timer in flickerTimers:
		timer.stop()
	
	# Turn all lights back on
	for light in allLights:
		light.visible = true
