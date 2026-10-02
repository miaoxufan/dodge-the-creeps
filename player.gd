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
var sprite_base_scale := Vector2.ONE
var gait_weight := 0.0
var visual_direction := Vector2.ZERO
var idle_time := 0.0
var step_lift := 0.0

func set_hero(id: int):
	hero_id = id
	var data = preload("res://hero_catalog.gd").get_hero(id)
	if not is_instance_valid(hero_sprite):
		hero_sprite = Sprite2D.new()
		add_child(hero_sprite)
	hero_sprite.texture = load(data.art)
	var texture_size = hero_sprite.texture.get_size()
	hero_sprite.scale = Vector2.ONE * 120.0 / texture_size.y
	sprite_base_scale = hero_sprite.scale
	hero_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	hero_sprite.offset = (Vector2(0.5,0.5)-data.anchor)*texture_size
	$AnimatedSprite2D.hide()
	var shape = CapsuleShape2D.new()
	shape.radius = 23
	shape.height = 66
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2.ZERO
	$CollisionShape2D.rotation = 0
	reset_walk_animation()
	queue_redraw()

func _ready():
	add_to_group("player")
	z_index = 2
	screen_size = get_viewport_rect().size

func _physics_process(_delta):
	# Re-check contact when protection expires, even if the bodies never separated.
	if visible and not $CollisionShape2D.disabled and has_overlapping_bodies():
		hit.emit()
	collect_overlapping_skill_orbs()

func collect_overlapping_skill_orbs():
	var main = get_parent()
	if not is_visible_in_tree() or get_tree().paused:
		return
	if not main.get("game_active") or main.get("game_finished"):
		return
	var body: CollisionShape2D = $CollisionShape2D
	if body.shape == null:
		return
	# Use the real transformed collider, including shrink upgrades. Temporary
	# damage immunity disables physics contact, but must not disable pickups.
	var bounds: Rect2 = body.global_transform * body.shape.get_rect()
	var amount := 0
	for orb in get_tree().get_nodes_in_group("skill_orbs"):
		if orb.is_queued_for_deletion() or orb.collected:
			continue
		var pickup: CollisionShape2D = orb.get_node("CollisionShape2D")
		if pickup.shape == null:
			continue
		var pickup_bounds: Rect2 = pickup.global_transform * pickup.shape.get_rect()
		if bounds.intersects(pickup_bounds, true) and body.shape.collide(body.global_transform, pickup.shape, pickup.global_transform):
			if orb.try_collect():
				amount += 1
	# Finish the entire batch before an upgrade pauses the scene tree.
	if amount > 0:
		main._on_skill_orb_collected(amount)

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

	var previous_position = position
	position += velocity * delta
	position = position.clamp(Vector2(36,165), screen_size-Vector2(36,48))
	# Actual displacement prevents running in place against an arena wall.
	update_walk_animation((position - previous_position) / maxf(delta, 0.0001), delta)
	queue_redraw()

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "right"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0

	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func reset_walk_animation():
	walk_time = 0.0
	idle_time = 0.0
	gait_weight = 0.0
	visual_direction = Vector2.ZERO
	step_lift = 0.0
	if is_instance_valid(hero_sprite):
		hero_sprite.position = Vector2.ZERO
		hero_sprite.rotation = 0.0
		hero_sprite.scale = sprite_base_scale
		hero_sprite.flip_h = false

func update_walk_animation(velocity: Vector2, delta: float):
	if not is_instance_valid(hero_sprite):
		return
	var moving := velocity.length() > 1.0
	# Frame-rate independent easing changes only artwork, never input response.
	var blend := 1.0 - exp(-14.0 * delta)
	gait_weight = lerpf(gait_weight, 1.0 if moving else 0.0, blend)
	visual_direction = visual_direction.lerp(velocity.normalized() if moving else Vector2.ZERO, blend)
	idle_time += delta * 2.4
	var pace := clampf(velocity.length() / 400.0, 0.65, 1.65)
	# Ranger: brisk stride. Duelist: light glide. Alchemist: weightier steps.
	var cadence: float = [10.5, 12.0, 9.0][hero_id - 1]
	var bounce: float = [3.6, 2.4, 4.2][hero_id - 1]
	walk_time += delta * cadence * pace * gait_weight
	var stride := sin(walk_time)
	var footfall := cos(walk_time * 2.0)
	step_lift = (1.0 - footfall) * 0.5 * bounce * gait_weight
	var breathing := sin(idle_time) * 0.009 * (1.0 - gait_weight)
	var squash := footfall * 0.022 * gait_weight
	var stretch := Vector2(1.0 + squash - breathing * 0.5, 1.0 - squash + breathing)
	var lean := visual_direction.x * 0.065 + stride * 0.035 * gait_weight
	hero_sprite.rotation = lean
	hero_sprite.scale = sprite_base_scale * stretch
	# Keep the feet near the ground when the illustration stretches/leans.
	var foot_anchor := Vector2(0, 38)
	var pivot_correction := foot_anchor - (foot_anchor * stretch).rotated(lean)
	hero_sprite.position = pivot_correction + Vector2(stride * 1.1 * gait_weight, -step_lift)
	if absf(velocity.x) > 1.0:
		hero_sprite.flip_h = velocity.x < 0.0

func start(pos):
	position = pos
	reset_walk_animation()
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
	var shadow_scale := 1.0 - step_lift * 0.015
	draw_set_transform(Vector2(0,33),0,Vector2(shadow_scale,0.32 * shadow_scale))
	draw_circle(Vector2.ZERO,26,Color(0.1,0.14,0.1,0.25))
	draw_set_transform(Vector2.ZERO)
	var main = get_parent()
	if "invulnerability_time_left" in main and main.invulnerability_time_left > 0:
		draw_arc(Vector2.ZERO,43,0,TAU,48,Color(1,0.89,0.56,0.85),2,true)
	if dash_unlocked:
		for i in range(dash_max_charges):
			draw_circle(Vector2((i-(dash_max_charges-1)*0.5)*10,48),3,Color("e9c06c") if i<dash_charges else Color("554f43"))
