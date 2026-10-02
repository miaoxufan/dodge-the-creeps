extends SceneTree

var main
var player
var failures := 0
const ORB = preload("res://skill_orb.tscn")

func _initialize():
	call_deferred("run")

func verify(value: bool, message: String):
	print(("PASS: " if value else "FAIL: ") + message)
	if not value:
		failures += 1

func orb_at(offset: Vector2):
	var orb = ORB.instantiate()
	main.add_child(orb)
	orb.global_position = player.global_position + offset
	return orb

func run():
	main = load("res://main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.get_node("HUD").persistence_enabled = false
	main.new_game()
	main.get_node("StartTimer").stop()
	main.game_active = true
	main.attack_cooldown = 999
	player = main.get_node("Player")
	player.set_hero(1)
	var batch: Array = []
	for i in range(64):
		batch.append(orb_at(Vector2.ZERO))
	var outside = orb_at(Vector2(100, 0))
	player.collect_overlapping_skill_orbs()
	verify(main.skill_level == 2 and main.skill_points == 19, "64 simultaneous pickups spend 15+30 and retain 19")
	verify(main.pending_upgrades.size() == 2 and paused, "both upgrades queued and game paused")
	verify(main.skill_points_to_next_level == 45, "next threshold remains 45")
	for orb in batch:
		verify(orb.collected and not orb.visible and orb.is_queued_for_deletion(), "batch orb removed before pause")
	verify(not outside.collected, "outside orb not collected")
	player.collect_overlapping_skill_orbs()
	verify(main.skill_points == 19, "paused or queued orbs cannot double count")
	paused = false
	main.pending_upgrades.clear()
	main.game_active = true
	main.skill_points = 0
	player.collect_overlapping_skill_orbs()
	verify(main.skill_points == 0, "queued deletion cannot double count after resume")
	var edge = orb_at(Vector2(30, 0))
	player.collect_overlapping_skill_orbs()
	verify(edge.collected, "orb radius counts even when its centre is outside capsule")
	player.scale = Vector2.ONE * 0.5
	var beyond_small = orb_at(Vector2(22, 0))
	var small_edge = orb_at(Vector2(19, 0))
	player.collect_overlapping_skill_orbs()
	verify(small_edge.collected and not beyond_small.collected, "shrink uses actual scaled collision area")
	player.get_node("CollisionShape2D").disabled = true
	var immune_orb = orb_at(Vector2.ZERO)
	player.collect_overlapping_skill_orbs()
	verify(immune_orb.collected, "damage immunity does not block pickup")
	var waiting = orb_at(Vector2.ZERO)
	paused = true
	player.collect_overlapping_skill_orbs()
	verify(not waiting.collected, "upgrade pause leaves pickups untouched")
	paused = false
	player.collect_overlapping_skill_orbs()
	verify(waiting.collected, "already overlapping orb collected after resume without re-entry")
	var hidden_orb = orb_at(Vector2.ZERO)
	player.hide()
	player.collect_overlapping_skill_orbs()
	verify(not hidden_orb.collected, "hidden player cannot collect")
	player.show()
	main.game_finished = true
	player.collect_overlapping_skill_orbs()
	verify(not hidden_orb.collected, "game over cannot collect")
	main.game_finished = false
	# Real physics-frame integration: no manual pickup call.
	await create_timer(0.1).timeout
	verify(not is_instance_valid(hidden_orb), "stationary overlap collected automatically on physics frame")
	print("SKILL PICKUP REGRESSION: %d failures" % failures)
	quit(1 if failures else 0)
