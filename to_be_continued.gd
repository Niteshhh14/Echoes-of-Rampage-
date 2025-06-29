extends Control

@onready var video = $VideoPlayer

func _ready():
	video.play()
	video.connect("finished", Callable(self, "_on_video_finished"))

func _on_video_finished():
	get_tree().change_scene_to_file("res://finale.tscn")
