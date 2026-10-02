extends SceneTree

func _initialize():
	call_deferred("run")

func capture(path: String):
	await create_timer(0.3).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func run():
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var hud = main.get_node("HUD")
	hud.persistence_enabled = false
	await capture("D:/codex/menu-art-preview.png")
	hud.select_hero(3)
	await capture("D:/codex/alchemist-menu-preview.png")
	hud.select_hero(2)
	await capture("D:/codex/duelist-menu-preview.png")
	hud.select_hero(3)
	hud.set_start_screen(false)
	main.new_game()
	main.get_node("StartTimer").stop()
	main._on_start_timer_timeout()
	main.invulnerability_time_left = 999
	for i in range(10):
		main._on_mob_timer_timeout()
	await create_timer(0.7).timeout
	await capture("D:/codex/battle-art-preview.png")
	main.queue_upgrade(false)
	hud.show_upgrade_choices(["multishot","bullet","life"],false)
	await capture("D:/codex/upgrade-art-preview.png")
	assert(paused)
	hud.hide_upgrade_choices()
	main._on_upgrade_selected("multishot")
	assert(not paused)
	assert(main.flask_radius == 127.0)
	assert(main.invulnerability_time_left > 0.9)
	main.get_node("MobTimer").stop()
	main.get_node("ScoreTimer").stop()
	main.game_active = false
	hud.set_start_screen(true)
	hud._on_leaderboard_button_pressed()
	await capture("D:/codex/leaderboard-art-preview.png")
	print("VISUAL SMOKE PASSED")
	quit()
