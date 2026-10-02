extends SceneTree

var failures := 0

func _initialize():
	call_deferred("run")

func verify(value: bool, message: String):
	print(("PASS: " if value else "FAIL: ") + message)
	if not value:
		failures += 1

func run():
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.get_node("HUD").persistence_enabled = false
	var player = main.get_node("Player")
	for id in range(1, 4):
		player.set_hero(id)
		var collider_transform = player.get_node("CollisionShape2D").transform
		var body_transform = player.transform
		var max_lift := 0.0
		for frame in range(120):
			player.update_walk_animation(Vector2(400, 0), 1.0 / 60.0)
			max_lift = maxf(max_lift, player.step_lift)
		verify(max_lift > 2.0 and max_lift < 5.0, "hero %d has bounded walking bounce" % id)
		verify(player.hero_sprite.rotation > 0.02, "directional lean")
		verify(player.transform == body_transform and player.get_node("CollisionShape2D").transform == collider_transform, "animation leaves gameplay geometry unchanged")
		player.update_walk_animation(Vector2(-400, 0), 1.0 / 60.0)
		verify(player.hero_sprite.flip_h, "left movement faces left")
		player.update_walk_animation(Vector2(0, -400), 1.0 / 60.0)
		verify(player.hero_sprite.flip_h, "vertical movement preserves facing")
		for frame in range(90):
			player.update_walk_animation(Vector2.ZERO, 1.0 / 60.0)
		verify(player.gait_weight < 0.001 and absf(player.hero_sprite.rotation) < 0.001, "stop eases into idle")
		verify(player.hero_sprite.modulate.a == 1.0 and player.hero_sprite.scale.x > 0, "animation never hides or collapses hero")
		player.reset_walk_animation()
		verify(player.hero_sprite.position == Vector2.ZERO and player.hero_sprite.scale == player.sprite_base_scale, "restart resets pose")
	# Actual movement input and arena clamping.
	player.show()
	player.position = Vector2(600, 400)
	Input.action_press("move_right")
	player._process(0.1)
	verify(is_equal_approx(player.position.x, 640), "movement remains responsive, without added inertia")
	player.position.x = player.screen_size.x - 36
	for frame in range(90):
		player._process(1.0 / 60.0)
	verify(player.gait_weight < 0.001, "pushing against wall settles to idle")
	Input.action_release("move_right")
	print("WALK ANIMATION: %d failures" % failures)
	quit(1 if failures else 0)
