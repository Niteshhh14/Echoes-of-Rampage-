extends Node2D

func _ready() -> void:
	Utils.saveGame()
	Utils.loadGame()
	var music = AudioStreamPlayer.new()
	add_child(music)
	music.stream = preload("res://Sounds/ogg/AMV. Sadness And Sorrow. (original) . Sad Naruto Childhood.ogg")
	music.volume_db = -5
	music.play()


func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://world.tscn")
	
