extends SceneTree

var main
var checks = 0
var failures = 0

func _initialize():
	call_deferred("run")

func check(condition: bool, message: String):
	if not condition:
		push_error("FAIL: " + message)
		failures += 1
		return
	checks += 1
	print("PASS: " + message)

func begin_hero(id: int):
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

func upgrade(choice: String, skill: bool = false):
	main.queue_upgrade(skill)
	check(paused,"upgrade pauses the world")
	main.get_node("HUD").hide_upgrade_choices()
	main._on_upgrade_selected(choice)
	main.get_node("MobTimer").stop()
	main.get_node("ScoreTimer").stop()
	check(not paused,"choice resumes the world")
	check(main.invulnerability_time_left >= 0.99,"one second protection after upgrade")

func run():
	main = load("res://main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var hud = main.get_node("HUD")
	hud.persistence_enabled = false
	check(main.get_node("StartTimer").one_shot,"start timer is one-shot")
	check(not main.get_node("Player").visible,"player hidden in menu")
	for id in range(1,4):
		await begin_hero(id)
		check(main.active_hero_id==id,"hero %d selection reaches gameplay" % id)
		check(main.get_node("Player").hero_sprite.texture != null,"hero %d has artwork" % id)
		check(main.get_node("Player/CollisionShape2D").position==Vector2.ZERO,"hero collision centred")
		var shape_before = main.get_node("Player/CollisionShape2D").shape.get_rect().size
		upgrade("small")
		check(main.get_node("Player").scale.is_equal_approx(Vector2.ONE*0.85),"shrinking affects entire player including collider")
		check(main.get_node("Player/CollisionShape2D").shape.get_rect().size==shape_before,"local shape remains stable")
		upgrade("life")
		check(main.lives==2,"extra life grants one life")
		upgrade("skill_dash",true)
		upgrade("skill_dash",true)
		check(main.get_node("Player").dash_max_charges==2,"dash stores multiple charges")
		if id==1:
			upgrade("multishot")
			upgrade("skill_multishot",true)
			check(main.front_bullet_count==2 and main.back_bullet_count==1,"front and rear upgrades stay separate")
			main.shoot_in_move_direction()
			check(get_nodes_in_group("projectiles").size()==3,"ranger fires three projectiles")
		elif id==2:
			check(main.knives.size()==2,"duelist starts with two blades")
			upgrade("skill_knife_count",true)
			check(main.knives.size()==3,"skill adds blade")
			check(not is_equal_approx(main.knives[0].rotation,main.knives[2].rotation),"added blade does not overlap")
			upgrade("skill_multishot",true)
			upgrade("multishot")
			check(main.knife_orbit_radius==145.0,"range boost applies to next range upgrade")
		else:
			upgrade("skill_multishot",true)
			upgrade("multishot")
			check(main.flask_radius==149.0,"alchemist radius upgrade doubles once")
			upgrade("skill_bullet",true)
			upgrade("bullet")
			check(is_equal_approx(main.flask_interval,1.1),"alchemist interval reduction doubles once")
			upgrade("skill_flask_count",true)
			check(main.flask_count==2,"alchemist extra flask")
	await begin_hero(3)
	check(main.get_node("Player").scale==Vector2.ONE and main.get_node("Player").speed==400,"restart resets size and speed")
	check(get_nodes_in_group("projectiles").is_empty(),"restart clears projectiles")
	var mob = main.mob_scene.instantiate()
	mob.position = Vector2(1100,500)
	mob.defeated.connect(main._on_mob_defeated)
	main.add_child(mob)
	var score_before = main.score
	mob.defeat()
	mob.defeat()
	check(main.score==score_before+1,"duplicate hits award once")
	await process_frame
	check(get_nodes_in_group("skill_orbs").size()==1,"kill drops exactly one skill orb")
	await begin_hero(3)
	check(get_nodes_in_group("skill_orbs").is_empty(),"restart clears skill orbs")
	for p in [Vector2(50,140),Vector2(800,450),Vector2(1550,850)]:
		for i in range(30):
			var spawn = main._get_safe_spawn_position(Vector2(1600,900),p,500)
			check(Rect2(0,0,1600,900).has_point(spawn) and spawn.distance_to(p)>=499.9,"spawn inside arena and outside safety radius")
	main.queue_upgrade(false)
	main.queue_upgrade(true)
	hud.hide_upgrade_choices()
	main._on_upgrade_selected("life")
	check(paused and main.pending_upgrades.size()==1,"simultaneous upgrades are queued")
	hud.hide_upgrade_choices()
	main._on_upgrade_selected("skill_dash")
	check(not paused and main.pending_upgrades.is_empty(),"queued upgrades resume after both choices")
	main.get_node("MobTimer").stop()
	main.get_node("ScoreTimer").stop()
	main.invulnerability_time_left=0
	main.lives=1
	main._on_player_hit()
	check(main.game_finished and not main.game_active,"fatal contact ends run")
	check(not main.get_node("Player").visible,"dead player hidden")
	main._on_start_timer_timeout()
	check(not main.game_active,"stale start timeout cannot restart dead run")
	await create_timer(3.2).timeout
	check(hud.get_node("StartButton").visible,"death returns to menu")
	print("REGRESSION: %d passed, %d failed" % [checks,failures])
	quit(1 if failures else 0)
