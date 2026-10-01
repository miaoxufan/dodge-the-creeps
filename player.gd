extends Area2D

signal hit

@export var speed = 400
var screen_size
var last_direction = Vector2.RIGHT
var dash_unlocked = false
var dash_max_charges = 0
var dash_charges = 0
var dash_distance = 180.0
var dash_recharge_time = 3.0
var dash_recharge_timer = 0.0

func _ready():
	add_to_group("player")
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2.ZERO

	if dash_unlocked:
		dash_recharge_timer -= delta
		if dash_charges < dash_max_charges and dash_recharge_timer <= 0.0:
			dash_charges += 1
			dash_recharge_timer = dash_recharge_time

		if Input.is_action_just_pressed("dash") and dash_charges > 0:
			position += last_direction * dash_distance
			position = position.clamp(Vector2.ZERO, screen_size)
			dash_charges -= 1
			dash_recharge_timer = dash_recharge_time

	if Input.is_action_pressed("move_right"):
		velocity.x += 1

	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if Input.is_action_pressed("move_down"):
		velocity.y += 1

	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		last_direction = velocity.normalized()
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "right"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0

	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func unlock_dash(additional_charges):
	dash_unlocked = true
	dash_max_charges += additional_charges
	dash_charges = dash_max_charges

func reset_dash():
	dash_unlocked = false
	dash_max_charges = 0
	dash_charges = 0
	dash_recharge_timer = 0.0

func _on_body_entered(body):
	hit.emit()
