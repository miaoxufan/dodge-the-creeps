extends SceneTree

# Short accelerated run; persistence is disabled and each hero gets a clean run.
func _initialize():
	call_deferred("run")

func run():
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var hud = main.get_node("HUD")
	hud.persistence_enabled = false
	Engine.time_scale = 4.0
	for id in range(1,4):
		hud.select_hero(id)
		hud.set_start_screen(false)
		main.new_game()
		main.get_node("StartTimer").stop()
		main._on_start_timer_timeout()
		var began = Time.get_ticks_msec()
		while Time.get_ticks_msec()-began < 8000:
			if paused:
				var choice = hud.current_upgrade_choices[0]
				hud.hide_upgrade_choices()
				main._on_upgrade_selected(choice)
			main.invulnerability_time_left = 999
			var t = (Time.get_ticks_msec()-began)*0.001
			main.get_node("Player").position = Vector2(800,450)+Vector2(cos(t),sin(t))*180
			main.get_node("Player").last_direction = Vector2(cos(t),sin(t))
			await process_frame
		print("SOAK hero=%d score=%d level=%d mobs=%d orbs=%d" % [id,main.score,main.level,get_nodes_in_group("mobs").size(),get_nodes_in_group("skill_orbs").size()])
	paused = false
	Engine.time_scale = 1
	print("SOAK COMPLETE: three accelerated runs")
	quit()
