extends CharacterBody2D
var SPEED=70
var GRAVITY=ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase=false
var health = 2  # You can tweak this value

func _ready() -> void:
	get_node("CollisionShape2D/AnimatedSprite2D").play("Idle")



func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta

	if chase:
		if get_node("CollisionShape2D/AnimatedSprite2D").animation != "Death":
			get_node("CollisionShape2D/AnimatedSprite2D").play("Attack")

			# Get player once if null
			if player == null and get_tree().get_nodes_in_group("player").size() > 0:
				player = get_tree().get_nodes_in_group("player")[0]

			if player != null:
				var direction = (player.position - self.position).normalized()

				get_node("CollisionShape2D/AnimatedSprite2D").flip_h = direction.x > 0
				velocity.x = direction.x * SPEED
			else:
				velocity.x = 0
	else:
		if get_node("CollisionShape2D/AnimatedSprite2D").animation != "Death":
			get_node("CollisionShape2D/AnimatedSprite2D").play("Idle")
			velocity.x = 0

	move_and_slide()

	
func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		chase=true


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name=="Player":
		chase=false 


func _on_player_death_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		Game.Gold+=1
		velocity.x=0
		chase=false
		$CollisionShape2D.disabled = true
		body.velocity.y = -200
		get_node("CollisionShape2D/AnimatedSprite2D").play("Death")
		await get_node("CollisionShape2D/AnimatedSprite2D").animation_finished
		self.queue_free()


func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		Game.playerHP-=2
		

func take_damage(amount):
	health -= amount

	if health <= 0:
		die()

func die():
	chase = false
	$CollisionShape2D.disabled = true
	get_node("CollisionShape2D/AnimatedSprite2D").play("Death")
	await get_node("CollisionShape2D/AnimatedSprite2D").animation_finished
	queue_free()
