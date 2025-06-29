extends Area2D

var speed = 800
var direction = Vector2.RIGHT  # will be set by player
var damage = 1
func _process(delta):
	position += direction * speed * delta

	# Despawn if off-screen
	if position.x < -500 or position.x > 8000:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
