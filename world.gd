extends Node2D

@onready var bleach_player = $BGMPlayerBleach
@onready var overtaken_player = $BGMPlayerOvertaken

func _ready():
	var music = AudioStreamPlayer.new()
	add_child(music)
	music.stream = preload("res://Sounds/ogg/Bleach OST On the Precipice of Defeat.ogg")
	music.volume_db = -5
	music.play()
