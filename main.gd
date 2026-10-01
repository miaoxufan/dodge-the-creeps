extends Node

@export var mob_scene: PackedScene
var bullet_scene = preload("res://bullet.tscn")

var score = 0
var game_active = false
var attack_cooldown = 0.0
var attack_interval = 0.45


func _process(delta):
	if not game_active:
		return

	attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		shoot_at_nearest_mob()
		attack_cooldown = attack_interval


func new_game():
	score = 0
	game_active = true
	attack_cooldown = 0.0

	$Player.start($StartPosition.position)

	$StartTimer.start()
	$ScoreTimer.start()
	$MobTimer.start()

	$HUD.update_score(score)
	$HUD.show_message("Get Ready")

	get_tree().call_group("mobs", "queue_free")


func game_over():
	game_active = false
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()


func shoot_at_nearest_mob():
	var nearest_mob = null
	var nearest_distance = INF

	for mob in get_tree().get_nodes_in_group("mobs"):
		if not is_instance_valid(mob):
			continue

		var distance = $Player.position.distance_squared_to(mob.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_mob = mob

	if nearest_mob == null:
		return

	var bullet = bullet_scene.instantiate()
	bullet.position = $Player.position
	bullet.direction = ($Player.position.direction_to(nearest_mob.position))
	add_child(bullet)


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
