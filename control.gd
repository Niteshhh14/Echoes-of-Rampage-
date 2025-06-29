extends Control

@onready var tnj_player = $tnj_player
@onready var knight = $KnightImage
@onready var text = $KnightImage/RichTextLabel
@onready var text2 = $KnightImage/RichTextLabel2
@onready var buttons = $Buttons
@onready var fade = $FadeLayer

func _ready() -> void:
	# Scene fade in
	fade.color.a = 1.0
	var fade_tween = create_tween()
	fade_tween.tween_property(fade, "color:a", 0.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Play music
	tnj_player.volume_db = -8
	tnj_player.play()

	# Initial visibility
	knight.modulate.a = 0
	text.modulate.a = 0
	text2.modulate.a = 0
	buttons.visible = false

	# Fade in knight
	var knight_tween = create_tween()
	knight_tween.tween_property(knight, "modulate:a", 1.0, 2.5).set_delay(0.5)

	# Fade in texts
	var tween1 = create_tween()
	tween1.tween_property(text, "modulate:a", 1.0, 2.5).set_delay(2.0)

	var tween2 = create_tween()
	tween2.tween_property(text2, "modulate:a", 1.0, 2.5).set_delay(4.0)

	# Show buttons after text
	await get_tree().create_timer(6.5).timeout
	buttons.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_mm_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
