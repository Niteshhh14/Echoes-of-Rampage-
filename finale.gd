extends Node2D

var slime_scene = preload("res://Mobs/Slime.tscn")
var slime_king_scene = preload("res://Mobs/SlimeBoss.tscn")

var wave_duration = 25.0
var spawn_interval = 0.5
var rampage_over = false

@onready var aot_player = $BGMPlayerAot
@onready var aot2_player = $BGMPlayerAot2
@onready var tnj_player = $BGMPlayerTnj

@onready var king = $SlimeKing

@onready var spawn_area1 = $SpawnArea
@onready var spawn_area2 = $SpawnArea2
@onready var left_wall = $LeftWall
@onready var right_wall = $RightWall

var spawn_timer
var wave_timer

func _ready():
	print("🧨 Player entered finale scene.")
	await get_tree().create_timer(1.0).timeout

	# Disable arena walls initially
	left_wall.visible = false
	right_wall.visible = false
	left_wall.get_node("CollisionShape2D").disabled = true
	right_wall.get_node("CollisionShape2D").disabled = true

	# Equip AK on player
	if get_tree().get_nodes_in_group("player").size() > 0:
		var player = get_tree().get_nodes_in_group("player")[0]
		player.equip_ak47()

	start_slime_rampage()

func start_slime_rampage():
	aot_player.play()
	print("⚠️ SLIME RAMPAGE STARTED")

	wave_timer = Timer.new()
	wave_timer.wait_time = wave_duration
	wave_timer.one_shot = true
	add_child(wave_timer)
	wave_timer.connect("timeout", Callable(self, "_on_wave_timeout"))
	wave_timer.start()

	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_slime"))
	spawn_timer.start()

func _on_spawn_slime():
	var slime = slime_scene.instantiate()

	var spawn_position: Vector2
	if randi() % 2 == 0:
		spawn_position = spawn_area1.global_position + Vector2(randf_range(-100, 100), 0)
	else:
		spawn_position = spawn_area2.global_position + Vector2(randf_range(-100, 100), 0)

	slime.position = spawn_position
	slime.chase = true  # 💥 this is the magic line
	get_tree().current_scene.add_child(slime)



func _on_wave_timeout():
	print("💀 RAMPAGE OVER")
	spawn_timer.queue_free()
	rampage_over = true

	# Optional: wait for slimes to be cleared
	await _wait_for_minions_to_die()

	# Wait 15 seconds before king shows up
	print("🕒 Waiting 15 seconds before King appears...")
	await get_tree().create_timer(12.0).timeout

	show_king_entrance()



func _wait_for_minions_to_die() -> void:
	while true:
		var slimes = get_tree().get_nodes_in_group("minions")  # <-- group all spawned slimes
		if slimes.size() == 0:
			break
		await get_tree().create_timer(0.5).timeout


func show_king_entrance():
	aot_player.stop()
	aot2_player.volume_db = -5  # Optional: make sure it's audible
	aot2_player.play()

	print("👑 THE KING APPROACHES...")

	if king:
		king.anim.play("Attack")
		await get_tree().create_timer(1.2).timeout

		# Activate arena lock + king chase
		king.chase = true
		left_wall.visible = true
		right_wall.visible = true
		left_wall.get_node("CollisionShape2D").disabled = false
		right_wall.get_node("CollisionShape2D").disabled = false

		print("📢 Boss CHASE ACTIVATED")
		print("🚧 Arena locked!")





func _on_boss_scene_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("⚠️ Something's coming...")
		_trigger_boss_warning()

func _on_boss_scene2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("⚠️ Something's coming...")
		_trigger_boss_warning()

func _on_boss_scene3_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("⚠️ Something's coming...")
		_trigger_boss_warning()

func _trigger_boss_warning():
	var cam = get_tree().get_nodes_in_group("player")[0].get_node("Camera2D")
	var tween = get_tree().create_tween()
	tween.tween_property(cam, "offset", Vector2(15, -15), 0.05).as_relative()
	tween.tween_property(cam, "offset", Vector2.ZERO, 0.05)

func unlock_arena():
	print("✅ Arena unlocked!")

	# Disable barriers
	left_wall.visible = false
	right_wall.visible = false
	left_wall.get_node("CollisionShape2D").disabled = true
	right_wall.get_node("CollisionShape2D").disabled = true

	# Final BGM switch
	if aot2_player and aot2_player.playing:
		print("Stopping AoT2 BGM")
		aot2_player.stop()

	print("Playing TNJ BGM")
	tnj_player.volume_db = -5  # Ensure it's audible
	tnj_player.play()
