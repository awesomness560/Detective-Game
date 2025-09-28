extends Node3D
#This will be the most jank script in the universe
#but you gotta do what you gotta do

@export var textures : Array[TextureRect]
@export var background : ColorRect
@export var newColorUnlock : Label
@export var normalPainting : Sprite3D
@export var screamingPainting : Sprite3D
@export var worldEnvironment : WorldEnvironment
@export var russoFinalLocation : Node3D
@export var music : AudioStreamPlayer

var currentConvo : int = 0

func _ready() -> void:
	Globals.unlocked.connect(foundSomething)
	Dialogic.timeline_ended.connect(onTimelineEnded)

func foundSomething(thing : int):
	if thing == 4:
		finalUnlockSequence()
		return
	Globals.clueTime.emit(true)
	#var playback = music.get_playback_position()
	#music.pitch_scale -= 0.1
	#music.seek(playback)
	textures[thing].visible = true
	background.show()
	currentConvo = thing
	#Globals.canMove = false
	match thing:
		0:
			#runDialogue("intro")
			pass
		1:
			screamingPainting.show()
			normalPainting.hide()
	await get_tree().create_timer(2).timeout
	
	onTimelineEnded()

func finalUnlockSequence():
	#dialogue
	var procederalMat : ProceduralSkyMaterial = worldEnvironment.environment.sky.sky_material as ProceduralSkyMaterial
	procederalMat.sky_top_color = Color.RED
	var russo : Node3D = get_tree().get_first_node_in_group("russo")
	russo.global_position.x = russoFinalLocation.global_position.x
	AudioServer.set_bus_effect_enabled(1, 0, true)
	music.pitch_scale = 0.5
	Globals.final.emit()
	pass

func runDialogue(dialogue : String):
	if Dialogic.current_timeline != null:
		return
	
	Dialogic.start(dialogue)

func onTimelineEnded():
	if currentConvo == 4:
		return
	
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
	Globals.convoFinished.emit(currentConvo)
