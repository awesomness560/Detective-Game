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
@export var creditsScene : PackedScene
@export var introCanvas : CanvasLayer
@export var cutscene1 : AnimatedSprite2D
@onready var label: Label = $Intro/Label
@onready var bg: ColorRect = $Intro/bg

var currentConvo : int = 0
var isInFinale : bool = false
var isCutscene : bool = true

func _ready() -> void:
	Globals.unlocked.connect(foundSomething)
	Dialogic.timeline_ended.connect(onTimelineEnded)
	Globals.canMove = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and isCutscene:
		label.hide()
		bg.hide()
		cutscene1.show()
		cutscene1.play("default")
		isCutscene = false
		await cutscene1.animation_finished
		introCanvas.queue_free()
		intro()

func intro():
	runDialogue("0intro")
	await Dialogic.timeline_ended
	Globals.canMove = true
	music.play()
	
	var name : String = Dialogic.VAR.playerName as String
	if name.to_lower() == "harper":
		finalUnlockSequence()

func foundSomething(thing : int):
	if thing == 4:
		finalFUCKYOU()
		return
	Globals.clueTime.emit(true)
	var playback = music.get_playback_position()
	music.pitch_scale -= 0.1
	music.seek(playback)
	textures[thing].visible = true
	background.show()
	currentConvo = thing
	Globals.canMove = false
	music.volume_db -= 10
	match thing:
		0:
			runDialogue("1tomescene")
		1:
			runDialogue("2photographscene")
			screamingPainting.show()
			normalPainting.hide()
		2:
			runDialogue("3receipt")
		3:
			runDialogue("4shard")
	#await get_tree().create_timer(2).timeout
	#
	#onTimelineEnded()

func finalFUCKYOU():
	isInFinale = true
	textures[4].show()
	background.show()
	Globals.canMove = false
	
	runDialogue("5finale")
	await Dialogic.timeline_ended
	
	runDialogue("6actualfinaleijustrealizedtheseshouldbeseparatesorrylol")
	await get_tree().create_timer(0.5).timeout
	await Dialogic.timeline_ended
	
	textures[4].hide()
	background.hide()
	Globals.canMove = true
	finalUnlockSequence()
	pass

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
	music.volume_db += 10
	Globals.clueTime.emit(false)
	Globals.convoFinished.emit(currentConvo)
	
	if currentConvo < 2:
		newColorUnlock.show()
		newColorUnlock.modulate.a = 1
	var tween := create_tween()
	tween.tween_property(newColorUnlock, "modulate:a", 0.0, 4)
	
	await tween.finished
	
	newColorUnlock.hide()


func _on_final_cutscene_area_entered(area: Area3D) -> void:
	if area.is_in_group("player") and isInFinale:
		music.volume_db -= 40
		runDialogue("7finaleforrealsies")
		Globals.canMove = false
		
		await Dialogic.timeline_ended
		
		music.stop()
		var credits = creditsScene.instantiate()
		add_child(credits)
