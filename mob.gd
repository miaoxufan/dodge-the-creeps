extends RigidBody2D

signal defeated
var is_defeated = false
var illustrated_sprite: Sprite2D
var motion_time = randf() * TAU
var variant = -1

func _ready():
	add_to_group("mobs")
	gravity_scale = 0.0
	linear_damp = 0.0
	lock_rotation = true
	collision_mask = 0
	rotation = 0.0
	$AnimatedSprite2D.hide()
	if variant < 0:
		variant = randi_range(0,2)
	illustrated_sprite = Sprite2D.new()
	illustrated_sprite.texture = load(["res://art/enemies/mushroom.png","res://art/enemies/bramble.png","res://art/enemies/ghost.png"][variant])
	illustrated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	illustrated_sprite.scale = Vector2.ONE * 92.0 / illustrated_sprite.texture.get_height()
	illustrated_sprite.flip_h = linear_velocity.x < 0
	add_child(illustrated_sprite)
	var shape = CircleShape2D.new()
	shape.radius = 28
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2.ZERO
	$CollisionShape2D.rotation = 0
	queue_redraw()

func _process(delta):
	motion_time += delta * (4.0 if variant == 2 else 9.0)
	illustrated_sprite.position.y = sin(motion_time) * 3
	illustrated_sprite.rotation = sin(motion_time*0.5) * 0.05

func _draw():
	draw_set_transform(Vector2(0,30),0,Vector2(1,0.3))
	draw_circle(Vector2.ZERO,28,Color(0.13,0.16,0.08,0.22))

func defeat():
	if is_defeated or is_queued_for_deletion():
		return
	is_defeated = true
	var pop = preload("res://combat_pop.gd").new()
	pop.position = position
	get_parent().call_deferred("add_child", pop)
	var orb = preload("res://skill_orb.tscn").instantiate()
	orb.position = position
	get_parent().call_deferred("add_child", orb)
	defeated.emit()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
