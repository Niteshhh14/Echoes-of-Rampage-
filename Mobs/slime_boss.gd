extends CharacterBody2D

var max_health = 100
var health = 100
var is_buff_phase = false
var SPEED = 60
var chase = false
var player: Node2D = null
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var slime_scene = preload("res://Mobs/Slime.tscn")
var minion_timer

@onready var anim = $CollisionShape2D/AnimatedSprite2D

func _ready():
	anim.play("Idle")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	velocity.y += GRAVITY * delta

	if chase and player:
		if anim.animation != "Death":
			anim.play("Attack")
			var direction = (player.position - self.position).normalized()
			velocity.x = direction.x * SPEED
			anim.flip_h = direction.x > 0
	else:
		if anim.animation != "Death":
			anim.play("Idle")
			velocity.x = 0

	move_and_slide()

func take_damage(amount):
	if health <= 0:
		return

	health -= amount
	print("👑 Slime King HP:", health)

	if health <= 0 and not is_buff_phase:
		# Phase 2 (Revival with rage)
		is_buff_phase = true
		health = max_health
		SPEED += 30
		anim.modulate = Color(1, 0.2, 0.2)
		start_minion_spawning()
		print("💢 Buff Phase Begins! King Slime Revived!")

		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			players[0].apply_buff()

	elif health <= 0 and is_buff_phase:
		anim.play("Death")
		print("👑 Slime King Defeated for real!")
		await anim.animation_finished
		queue_free()
		var finale = get_tree().current_scene
		finale.unlock_arena()
		get_tree().change_scene_to_file("res://Outro.tscn")



func _on_player_collision_body_entered(body):
	if body.name == "Player":
		Game.playerHP -= 5

func _on_player_death_body_entered(body):
	if body.name == "Player":
		$CollisionShape2D.disabled = true
		body.velocity.y = -200
		anim.play("Death")
		await anim.animation_finished
		queue_free()
		var finale = get_tree().current_scene
		finale.unlock_arena()
		get_tree().change_scene_to_file("res://Outro.tscn")

func start_minion_spawning():
	minion_timer = Timer.new()
	minion_timer.wait_time = 1.5
	minion_timer.autostart = true
	minion_timer.one_shot = false
	add_child(minion_timer)
	minion_timer.connect("timeout", Callable(self, "_spawn_minion"))

func _spawn_minion():
	var minion = slime_scene.instantiate()
	minion.position = self.position + Vector2(randf_range(-100, 100), 0)
	minion.chase = true
	get_tree().current_scene.add_child(minion)

	if minion_timer.wait_time > 0.6:
		minion_timer.wait_time -= 0.1
