extends Node

var prevTrackIndex: int = -1
var currentTrackIndex: int = 0
var timeSinceTrackChange: float = 0.0
var changingTracks: bool = false

@export var trackSilentVolume: float = -25
@export var trackFullVolume: float = -5

func _process(delta):
	if(changingTracks):
		timeSinceTrackChange += 1.0 * delta
		timeSinceTrackChange = min(timeSinceTrackChange, 1.0)
		get_child(prevTrackIndex).volume_db = lerp(trackFullVolume, trackSilentVolume, timeSinceTrackChange)
		get_child(currentTrackIndex).volume_db = lerp(trackSilentVolume, trackFullVolume, timeSinceTrackChange)
		if(timeSinceTrackChange >= 1.0):
			get_child(prevTrackIndex).stop()

func ChangeTrack(newTrack: int) -> void:
	timeSinceTrackChange = 0
	prevTrackIndex = currentTrackIndex
	currentTrackIndex = newTrack
	changingTracks = prevTrackIndex != currentTrackIndex
	if(changingTracks):
		get_child(currentTrackIndex).play()

func OnTrackFinished(trackIndex: int) -> void:
	if(trackIndex == currentTrackIndex):
		get_child(currentTrackIndex).play()

func PlayGeneral(index: int):
	$GeneralEffects.get_child(index).play()

func PlayGeneralByName(nodeName: String):
	$GeneralEffects.get_node(nodeName).play()
