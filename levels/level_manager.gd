extends Node3D
#This will be the most jank script in the universe
#but you gotta do what you gotta do

@export var textures : Array[TextureRect]
@export var background : ColorRect
@export var newColorUnlock : Label

func _ready() -> void:
	Globals.unlocked.connect(foundSomething)
	Dialogic.timeline_ended.connect(onTimelineEnded)

func foundSomething(thing : int):
	if thing == 4:
		finalUnlockSequence()
		return
	Globals.clueTime.emit(true)
	textures[thing].visible = true
	background.show()
	#Globals.canMove = false
	#match thing:
		#0:
			#runDialogue("intro")
	await get_tree().create_timer(2).timeout
	
	onTimelineEnded()

func finalUnlockSequence():
	pass

func runDialogue(dialogue : String):
	if Dialogic.current_timeline != null:
		return
	
	Dialogic.start(dialogue)

func onTimelineEnded():
	for texture in textures:
		texture.hide()
	
	background.hide()
	Globals.canMove = true
	
	newColorUnlock.show()
	newColorUnlock.modulate.a = 1
	var tween := create_tween()
	tween.tween_property(newColorUnlock, "modulate:a", 0.0, 4)
	
	await tween.finished
	
	newColorUnlock.hide()
	
	Globals.clueTime.emit(false)
