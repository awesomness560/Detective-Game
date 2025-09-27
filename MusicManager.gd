extends Node

@export var room1_music: AudioStream
@export var room2_music: AudioStream
@export var room3_music: AudioStream
@export var room4_music: AudioStream

@onready var _player: AudioStreamPlayer = AudioStreamPlayer.new()
var _current_room: int = -1

func _ready() -> void:
	add_child(_player)
	_player.bus = "Music"  # make sure you have a "Music" bus in Audio panel, or leave default
	_player.autoplay = false
	_player.volume_db = 0.0

	# start with room 1 by default
	play_room_music(1)


func play_room_music(room_id: int) -> void:
	if room_id == _current_room:
		return  # already playing
	_current_room = room_id

	var new_stream: AudioStream = null
	match room_id:
		1: new_stream = room1_music
		2: new_stream = room2_music
		3: new_stream = room3_music
		4: new_stream = room4_music

	if new_stream:
		_player.stop()
		_player.stream = new_stream
		_player.play()
