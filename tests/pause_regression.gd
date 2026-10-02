extends SceneTree
var failures := 0

func _initialize():
	call_deferred("run")

func verify(value: bool, message: String):
	print(("PASS: " if value else "FAIL: ") + message)
	if not value: failures += 1

func escape(hud):
	var event = InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	hud._input(event)

func run():
	var main = load("res://main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var hud = main.get_node("HUD")
	hud.persistence_enabled = false
	escape(hud)
	verify(not paused, "ESC does not pause title screen")
	hud.set_start_screen(false)
	main.new_game()
	escape(hud)
	var start_left = main.get_node("StartTimer").time_left
	var message_left = hud.get_node("MessageTimer").time_left
	await create_timer(0.15).timeout
	verify(paused and hud.pause_overlay.visible, "ESC opens pause menu")
	verify(is_equal_approx(start_left, main.get_node("StartTimer").time_left), "Get Ready countdown frozen")
	verify(is_equal_approx(message_left, hud.get_node("MessageTimer").time_left), "Get Ready message frozen")
	escape(hud)
	verify(not paused and not hud.pause_overlay.visible, "second ESC resumes")
	main.get_node("StartTimer").stop()
	main._on_start_timer_timeout()
	escape(hud)
	var score = main.score
	var shield = main.invulnerability_time_left
	var player_pos = main.get_node("Player").position
	Input.action_press("move_right")
	await create_timer(0.15).timeout
	Input.action_release("move_right")
	verify(main.score == score and main.invulnerability_time_left == shield and main.get_node("Player").position == player_pos, "pause freezes gameplay, shield, and movement")
	hud.get_node("PauseMenu/Panel/Resume").pressed.emit()
	verify(not paused, "continue button resumes")
	main.queue_upgrade(false)
	escape(hud)
	verify(paused and hud.pause_overlay.visible, "ESC menu works over upgrade selection")
	escape(hud)
	verify(paused and hud.get_node("UpgradePanel").visible, "closing ESC menu preserves upgrade pause")
	main._on_upgrade_selected("speed")
	verify(not paused, "choosing upgrade resumes normally")
	print("PAUSE REGRESSION: %d failures" % failures)
	if failures:
		quit(1)
	else:
		# Exercise the real exit button without touching persistent scores.
		escape(hud)
		hud.get_node("PauseMenu/Panel/Quit").pressed.emit()
