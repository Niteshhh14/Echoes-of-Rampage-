extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var has_ak = false
var can_shoot = true

var is_buffed = false
var fire_rate = 0.1  # seconds between shots (default)
var buffed_fire_rate = 0.05
var damage = 1
var buffed_damage = 1.5


@onready var anim = $AnimationPlayer
@onready var ak = $AKGun
@onready var muzzle = $AKGun/Muzzle
@onready var cooldown = $FireCooldown
@onready var camera = $Camera2D

func _ready():
	add_to_group("player")

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jumping
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("Jump")

	# Movement
	var direction = Input.get_axis("left", "right")
# Flip player sprite
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
		ak.scale.x = -1  # flip gun left
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false
		ak.scale.x = 1   # flip gun right


	if direction != 0:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			anim.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			anim.play("Idle")

	if velocity.y > 0:
		anim.play("Fall")

	move_and_slide()

	# Shooting
	if has_ak and Input.is_action_pressed("fire") and can_shoot:
		shoot_ak()
		can_shoot = false
		cooldown.wait_time = fire_rate  # dynamically use current fire rate
		cooldown.start()


	# Health check
	if Game.playerHP <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://main.tscn")

func _shake_camera():
	if camera:
		var tween = get_tree().create_tween()
		var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		tween.tween_property(camera, "offset", shake_offset, 0.05).as_relative()
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)


func equip_ak47():
	has_ak = true
	ak.visible = true

func shoot_ak():
	var bullet = preload("res://Bullet.tscn").instantiate()
	bullet.position = muzzle.global_position
	_shake_camera()
	bullet.damage = damage

	if $AnimatedSprite2D.flip_h:
		bullet.direction = Vector2.LEFT
		bullet.scale.x = -1
	else:
		bullet.direction = Vector2.RIGHT
		bullet.scale.x = 1
	# Flash effect
	var flash = muzzle.get_node("MuzzleFlash")
	flash.visible = true
	flash.modulate.a = 1.0
	flash.scale = Vector2(randf() * 0.5 + 0.75, randf() * 0.5 + 0.75)  # Random scale for flavor

	await get_tree().create_timer(0.05).timeout
	flash.visible = false
	if muzzle.has_node("Ak_Gunshotsound"):
		var sound = muzzle.get_node("Ak_Gunshotsound")
		sound.play()
	else:
		print("Gunshot sound node not found!")

	get_tree().current_scene.add_child(bullet)

func apply_buff():
	if not is_buffed:
		is_buffed = true
		fire_rate = buffed_fire_rate
		damage = buffed_damage
		print("🔥 AK BUFFED! Faster fire rate and more damage!")
		# You could add a visual glow or sound effect here


func _on_FireCooldown_timeout():
	can_shoot = true


func _on_void_death_body_entered(body: Node2D) -> void:
	Game.playerHP=0
	print("💀 Fell into void.")


func _on_finaleboss_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("🕳️ Player jumped! Loading boss arena...")
		get_tree().change_scene_to_file("res://TO_BE_CONTINUED.tscn")
