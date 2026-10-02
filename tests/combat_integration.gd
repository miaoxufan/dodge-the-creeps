extends SceneTree
var main
var failures = 0

func _initialize():
	call_deferred("run")

func verify(value: bool, message: String):
	print(("PASS: " if value else "FAIL: ")+message)
	if not value: failures += 1

func begin(id):
	main.get_node("HUD").select_hero(id)
	main.get_node("HUD").set_start_screen(false)
	main.new_game()
	main.get_node("StartTimer").stop()
	await process_frame
	main._on_start_timer_timeout()
	main.get_node("MobTimer").stop()
	main.get_node("ScoreTimer").stop()
	main.attack_cooldown = 999
	main.invulnerability_time_left = 999

func spawn_at(pos):
	var mob = main.mob_scene.instantiate()
	mob.position = pos
	mob.freeze = true
	mob.defeated.connect(main._on_mob_defeated)
	main.add_child(mob)
	return mob

func run():
	main = load("res://main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.get_node("HUD").persistence_enabled = false
	for id in range(1,4):
		await begin(id)
		var player = main.get_node("Player")
		spawn_at(player.position+Vector2(140,0))
		if id==1:
			player.last_direction=Vector2.RIGHT
			main.shoot_in_move_direction()
		if id==3:
			main.throw_flasks()
		await create_timer(1.0).timeout
		verify(main.score==1,"hero %d actually kills through physics/area damage" % id)
		verify(get_nodes_in_group("skill_orbs").size()==1,"hero %d drops one orb" % id)
		if not get_nodes_in_group("skill_orbs").is_empty():
			player.position=get_nodes_in_group("skill_orbs")[0].position
			await create_timer(0.15).timeout
			verify(main.skill_points==1,"actual player overlap picks up orb")
	await begin(1)
	main.invulnerability_time_left=0.4
	spawn_at(main.get_node("Player").position)
	await create_timer(0.1).timeout
	verify(not main.game_finished,"protection blocks overlapping enemy")
	await create_timer(0.5).timeout
	verify(main.game_finished,"continuous overlap hurts after protection expires")
	print("COMBAT INTEGRATION: %d failures" % failures)
	quit(1 if failures else 0)
