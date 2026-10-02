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
var hero_sprite: Sprite2D
var walk_time = 0.0
var hero_id = 1

func set_hero(id: int):
	hero_id = id
	var data = preload("res://hero_catalog.gd").get_hero(id)
	if not is_instance_valid(hero_sprite):
		hero_sprite = Sprite2D.new()
		add_child(hero_sprite)
	hero_sprite.texture = load(data.art)
	var texture_size = hero_sprite.texture.get_size()
	hero_sprite.scale = Vector2.ONE * 120.0 / texture_size.y
	hero_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	hero_sprite.offset = (Vector2(0.5,0.5)-data.anchor)*texture_size
	$AnimatedSprite2D.hide()
	var shape = CapsuleShape2D.new()
	shape.radius = 23
	shape.height = 66
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2.ZERO
	$CollisionShape2D.rotation = 0
	queue_redraw()

func _ready():
	add_to_group("player")
	z_index = 2
	screen_size = get_viewport_rect().size

func _physics_process(_delta):
	# Re-check contact when protection expires, even if the bodies never separated.
	if visible and not $CollisionShape2D.disabled and has_overlapping_bodies():
		hit.emit()

func _process(delta):
	if not visible:
		return
	screen_size = get_viewport_rect().size
	var velocity = Vector2.ZERO

	if dash_unlocked:
		dash_recharge_timer -= delta
		if dash_charges < dash_max_charges and dash_recharge_timer <= 0.0:
			dash_charges += 1
			dash_recharge_timer = dash_recharge_time

		if Input.is_action_just_pressed("dash") and dash_charges > 0:
			position += last_direction * dash_distance
			position = position.clamp(Vector2(36,165), screen_size-Vector2(36,48))
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
	position = position.clamp(Vector2(36,165), screen_size-Vector2(36,48))
	if is_instance_valid(hero_sprite):
		walk_time += delta * (14.0 if velocity.length() > 0 else 3.0)
		hero_sprite.position.y = sin(walk_time) * (2.5 if velocity.length() > 0 else 0.6)
		hero_sprite.rotation = sin(walk_time*0.5)*0.035 if velocity.length() > 0 else 0.0
		if velocity.x != 0:
			hero_sprite.flip_h = velocity.x < 0
	queue_redraw()

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
	$CollisionShape2D.set_deferred("disabled", false)
	modulate = Color.WHITE

func unlock_dash(additional_charges):
	dash_unlocked = true
	dash_max_charges += additional_charges
	dash_charges = dash_max_charges

func reset_dash():
	dash_unlocked = false
	dash_max_charges = 0
	dash_charges = 0
	dash_recharge_timer = 0.0

func _on_body_entered(_body):
	hit.emit()

func _draw():
	# The shadow marks the actual body centre, not the cape or held weapon.
	draw_set_transform(Vector2(0,33),0,Vector2(1,0.32))
	draw_circle(Vector2.ZERO,26,Color(0.1,0.14,0.1,0.25))
	draw_set_transform(Vector2.ZERO)
	var main = get_parent()
	if "invulnerability_time_left" in main and main.invulnerability_time_left > 0:
		draw_arc(Vector2.ZERO,43,0,TAU,48,Color(1,0.89,0.56,0.85),2,true)
	if dash_unlocked:
		for i in range(dash_max_charges):
			draw_circle(Vector2((i-(dash_max_charges-1)*0.5)*10,48),3,Color("e9c06c") if i<dash_charges else Color("554f43"))
