extends StaticBody2D

func _on_akcrate_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.equip_ak47()

		# Find and fade out the current BGM
		for child in get_tree().current_scene.get_children():
			if child is AudioStreamPlayer:
				var fade_out = get_tree().create_tween()
				fade_out.tween_property(child, "volume_db", -40, 1.5)
				await fade_out.finished
				child.queue_free()

		# Create and fade in Overtaken
		var overtaken_music = AudioStreamPlayer.new()
		overtaken_music.stream = preload("res://Sounds/ogg/One Piece OST_ Overtaken.ogg")
		overtaken_music.volume_db = -40  # start quiet
		get_tree().current_scene.add_child(overtaken_music)
		overtaken_music.play()

		var fade_in = get_tree().create_tween()
		fade_in.tween_property(overtaken_music, "volume_db", -5, 1.0)

		queue_free()
