extends Node

@export var mob_scene: PackedScene

var score = 0


func new_game():
	score = 0

	$Player.start($StartPosition.position)

	$StartTimer.start()
	$ScoreTimer.start()
	$MobTimer.start()

	$HUD.update_score(score)
	$HUD.show_message("Get Ready")

	get_tree().call_group("mobs", "queue_free")


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()


func _on_start_timer_timeout():
	$MobTimer.start()


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size

	var spawn_position = Vector2.ZERO
	var min_distance = 300.0

	# 最多尝试 20 次，寻找离玩家足够远的位置
	for i in range(20):
		spawn_position = Vector2(
			randf_range(50, screen_size.x - 50),
			randf_range(50, screen_size.y - 50)
		)

		if spawn_position.distance_to($Player.position) >= min_distance:
			break

	mob.position = spawn_position

	# 朝玩家方向移动
	var direction = ($Player.position - mob.position).normalized()
	var speed = randf_range(150, 250)

	mob.linear_velocity = direction * speed
	mob.rotation = direction.angle()

	add_child(mob)


func _on_player_hit():
	game_over()
