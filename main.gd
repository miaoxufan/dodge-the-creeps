extends Node

@export var mob_scene: PackedScene
var bullet_scene = preload("res://bullet.tscn")
var knife_scene = preload("res://knife.tscn")

var score = 0
var skill_points = 0
var skill_level = 0
var skill_points_to_next_level = 15
var experience = 0
var level = 1
var experience_to_next_level = 5
var game_active = false
var attack_cooldown = 0.0
var attack_interval = 0.45
var bullet_speed = 700.0
var front_bullet_count = 1
var back_bullet_count = 0
var lives = 1
var hit_invulnerable = false
var invulnerability_time_left = 0.0
var next_move_upgrade_multiplier = 1.0
var next_bullet_upgrade_multiplier = 1.0
var next_knife_speed_upgrade_multiplier = 1.0
var next_knife_range_upgrade_multiplier = 1.0
var next_shrink_scale = 0.85
var spawn_index = 0
var game_finished = false
var active_hero_id = 1
var front_knife_count = 2
var back_knife_count = 0
var knife_speed = 5.5
var knife_orbit_radius = 55.0
var knives = []
var flask_radius = 105.0
var flask_interval = 1.4
var flask_count = 1
var next_flask_radius_multiplier = 1.0
var next_flask_speed_multiplier = 1.0
var pending_upgrades: Array[bool] = []

func _ready():
	var backdrop = preload("res://arena_backdrop.gd").new()
	add_child(backdrop)
	$StartTimer.one_shot = true
	$Player.hide()
	$Player/CollisionShape2D.set_deferred("disabled", true)


func _process(delta):
	if invulnerability_time_left > 0.0:
		invulnerability_time_left = max(0.0, invulnerability_time_left - delta)

	if not game_active:
		return
	if active_hero_id == 2:
		return

	attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		if active_hero_id == 3:
			throw_flasks()
			attack_cooldown = flask_interval
		else:
			shoot_in_move_direction()
			attack_cooldown = attack_interval


func new_game():
	get_tree().paused = false
	active_hero_id = $HUD.get_selected_hero_id()
	clear_knives()
	get_tree().call_group("projectiles", "queue_free")
	pending_upgrades.clear()
	flask_radius = 105.0
	flask_interval = 1.4
	flask_count = 1
	next_flask_radius_multiplier = 1.0
	next_flask_speed_multiplier = 1.0
	score = 0
	spawn_index = 0
	skill_points = 0
	skill_level = 0
	skill_points_to_next_level = 15
	experience = 0
	level = 1
	experience_to_next_level = 5
	game_active = false
	game_finished = false
	attack_cooldown = 0.0
	attack_interval = 0.45
	bullet_speed = 700.0
	front_bullet_count = 1
	back_bullet_count = 0
	front_knife_count = 2
	back_knife_count = 0
	knife_speed = 5.5
	knife_orbit_radius = 55.0
	lives = 1
	hit_invulnerable = false
	invulnerability_time_left = 3.0
	next_move_upgrade_multiplier = 1.0
	next_bullet_upgrade_multiplier = 1.0
	next_knife_speed_upgrade_multiplier = 1.0
	next_knife_range_upgrade_multiplier = 1.0
	next_shrink_scale = 0.85
	$MobTimer.wait_time = 0.5
	$Player.scale = Vector2.ONE
	$Player.reset_dash()
	$Player.speed = 400
	$Player.modulate = Color.WHITE
	$Player.set_hero(active_hero_id)
	$StartPosition.position = get_viewport().get_visible_rect().size * 0.5

	$Player.start($StartPosition.position)
	if active_hero_id == 2:
		rebuild_knives()

	$StartTimer.wait_time = 3.0
	$StartTimer.start()
	$ScoreTimer.stop()
	$MobTimer.stop()

	$HUD.update_score(score)
	$HUD.update_skill_points(skill_points, skill_points_to_next_level)
	$HUD.update_level(level, experience, experience_to_next_level)
	$HUD.update_lives(lives)
	$HUD.hide_upgrade_choices()
	$HUD/MessageTimer.wait_time = 3.0
	$HUD.show_message("准备出发 · 3 秒保护")

	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("skill_orbs", "queue_free")


func game_over():
	if game_finished:
		return
	game_finished = true
	get_tree().paused = false
	game_active = false
	$StartTimer.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$Player.hide()
	$Player.get_node("CollisionShape2D").set_deferred("disabled", true)
	clear_knives()
	get_tree().call_group("projectiles", "queue_free")
	$HUD.record_score(score)
	$HUD.show_game_over()


func shoot_in_move_direction():
	var direction = $Player.last_direction

	for i in range(front_bullet_count):
		var bullet = bullet_scene.instantiate()
		var spread = (i - (front_bullet_count - 1) / 2.0) * 0.08
		var shot_direction = direction.rotated(spread)

		# 每条子弹都从角色身体中心生成
		bullet.position = $Player.position
		bullet.direction = shot_direction
		bullet.speed = bullet_speed
		add_child(bullet)

	for i in range(back_bullet_count):
		var bullet = bullet_scene.instantiate()
		var spread = (i - (back_bullet_count - 1) / 2.0) * 0.08
		var shot_direction = direction.rotated(PI + spread)

		bullet.position = $Player.position
		bullet.direction = shot_direction
		bullet.speed = bullet_speed
		add_child(bullet)


func _on_start_timer_timeout():
	if game_finished:
		return
	game_active = true
	invulnerability_time_left = 0.0
	$HUD/MessageTimer.wait_time = 2.0
	$HUD/Message.hide()
	$ScoreTimer.start()
	$MobTimer.start()


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

	# 随着游戏进行，敌人出现得越来越频繁
	$MobTimer.wait_time = max(0.2, 0.5 - score * 0.005)


func _on_mob_defeated():
	if game_finished:
		return
	experience += 1
	score += 1
	$HUD.update_score(score)

	if experience >= experience_to_next_level:
		experience = 0
		level += 1
		experience_to_next_level += 3
		queue_upgrade(false)

	$HUD.update_level(level, experience, experience_to_next_level)


func _on_skill_orb_collected(amount: int = 1):
	if game_finished or amount <= 0:
		return
	skill_points += amount

	while skill_points >= skill_points_to_next_level:
		skill_points -= skill_points_to_next_level
		skill_level += 1
		skill_points_to_next_level += 15
		queue_upgrade(true)
	$HUD.update_skill_points(skill_points, skill_points_to_next_level)

func queue_upgrade(is_skill: bool):
	pending_upgrades.append(is_skill)
	if pending_upgrades.size() == 1:
		present_upgrade()

func present_upgrade():
	game_active = false
	$MobTimer.stop()
	$ScoreTimer.stop()
	get_tree().paused = true
	var is_skill = pending_upgrades[0]
	var choices = ["skill_multishot", "skill_speed", "skill_bullet", "skill_small", "skill_dash"] if is_skill else ["multishot", "speed", "bullet", "small", "life"]
	if is_skill and active_hero_id == 2:
		choices.append("skill_knife_count")
	if is_skill and active_hero_id == 3:
		choices.append("skill_flask_count")
	choices.shuffle()
	$HUD.show_upgrade_choices(choices.slice(0, 3), is_skill)


func _on_upgrade_selected(choice):
	get_tree().paused = false
	invulnerability_time_left = 1.0

	if choice == "skill_multishot":
		if active_hero_id == 3:
			next_flask_radius_multiplier = 2.0
		elif active_hero_id == 2:
			next_knife_range_upgrade_multiplier = 2.0
		else:
			back_bullet_count += 1
	elif choice == "skill_flask_count":
		flask_count += 1
	elif choice == "skill_knife_count":
		if active_hero_id == 2:
			back_knife_count += 1
			rebuild_knives()
	elif choice == "skill_speed":
		next_move_upgrade_multiplier = 2.0
	elif choice == "skill_bullet":
		if active_hero_id == 3:
			next_flask_speed_multiplier = 2.0
		elif active_hero_id == 2:
			next_knife_speed_upgrade_multiplier = 2.0
		else:
			next_bullet_upgrade_multiplier = 2.0
	elif choice == "skill_small":
		next_shrink_scale = 0.70
	elif choice == "skill_dash":
		$Player.unlock_dash(1)
	elif choice == "multishot":
		if active_hero_id == 3:
			flask_radius += 22.0 * next_flask_radius_multiplier
			next_flask_radius_multiplier = 1.0
		elif active_hero_id == 2:
			knife_orbit_radius += 45.0 * next_knife_range_upgrade_multiplier
			next_knife_range_upgrade_multiplier = 1.0
			rebuild_knives()
		else:
			front_bullet_count += 1
	elif choice == "speed":
		$Player.speed += int(50 * next_move_upgrade_multiplier)
		next_move_upgrade_multiplier = 1.0
	elif choice == "bullet":
		if active_hero_id == 3:
			flask_interval = maxf(0.35, flask_interval - 0.15 * next_flask_speed_multiplier)
			next_flask_speed_multiplier = 1.0
		elif active_hero_id == 2:
			knife_speed += 0.8 * next_knife_speed_upgrade_multiplier
			next_knife_speed_upgrade_multiplier = 1.0
			rebuild_knives()
		else:
			bullet_speed += int(150 * next_bullet_upgrade_multiplier)
			next_bullet_upgrade_multiplier = 1.0
	elif choice == "small":
		$Player.scale *= next_shrink_scale
		next_shrink_scale = 0.85
	elif choice == "life":
		lives += 1
		$HUD.update_lives(lives)

	if not pending_upgrades.is_empty():
		pending_upgrades.pop_front()
	if not pending_upgrades.is_empty():
		present_upgrade()
		return
	game_active = true
	$ScoreTimer.start()
	$MobTimer.start()


func clear_knives():
	for blade in knives:
		if is_instance_valid(blade):
			blade.queue_free()
	knives.clear()


func rebuild_knives():
	if active_hero_id != 2:
		return
	clear_knives()
	var total = max(front_knife_count + back_knife_count, 1)
	for index in range(total):
		var blade = knife_scene.instantiate()
		add_child(blade)
		blade.setup($Player, TAU * index / total, knife_speed, knife_orbit_radius)
		knives.append(blade)

func throw_flasks():
	var targets = get_tree().get_nodes_in_group("mobs").filter(func(m): return not m.is_queued_for_deletion())
	targets.sort_custom(func(a,b): return a.position.distance_squared_to($Player.position) < b.position.distance_squared_to($Player.position))
	for i in range(flask_count):
		var flask = preload("res://alchemy_flask.gd").new()
		flask.position = $Player.position
		flask.target = $Player.position + $Player.last_direction.rotated(i*0.4) * 220.0
		if not targets.is_empty():
			var target = targets[i % targets.size()]
			flask.target = target.position + target.linear_velocity * 0.3
		flask.target = flask.target.clamp(Vector2(25,105),get_viewport().get_visible_rect().size-Vector2(25,25))
		flask.blast_radius = flask_radius
		add_child(flask)


func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size

	var spawn_position = Vector2.ZERO
	var min_distance = 500.0
	spawn_position = _get_safe_spawn_position(screen_size, $Player.position, min_distance)

	mob.position = spawn_position

	# 朝玩家方向移动
	var direction = ($Player.position - mob.position).normalized()
	# 等级越高，敌人移动速度越快
	var speed_bonus = min(level * 5.0, 60.0)
	var speed = randf_range(150 + speed_bonus, 250 + speed_bonus)

	mob.linear_velocity = direction * speed
	mob.rotation = 0.0
	mob.defeated.connect(_on_mob_defeated)

	add_child(mob)


func _get_safe_spawn_position(screen_size, player_position, min_distance):
	var margin = 50.0
	var corners = [
		Vector2(margin, 140.0),
		Vector2(screen_size.x - margin, 140.0),
		Vector2(screen_size.x - margin, screen_size.y - margin),
		Vector2(margin, screen_size.y - margin)
	]
	var valid_segments = []
	var total_length = 0.0

	# 把四条边按“距离玩家是否达到安全距离”切分。
	for edge_index in range(4):
		var start = corners[edge_index]
		var end = corners[(edge_index + 1) % 4]
		var edge_vector = end - start
		var edge_length = edge_vector.length()
		var relative_start = start - player_position
		var a = edge_vector.length_squared()
		var b = 2.0 * relative_start.dot(edge_vector)
		var c = relative_start.length_squared() - min_distance * min_distance
		var cuts = [0.0, 1.0]
		var discriminant = b * b - 4.0 * a * c

		if discriminant > 0.0:
			var root_distance = sqrt(discriminant)
			cuts.append(clamp((-b - root_distance) / (2.0 * a), 0.0, 1.0))
			cuts.append(clamp((-b + root_distance) / (2.0 * a), 0.0, 1.0))
		cuts.sort()

		for cut_index in range(cuts.size() - 1):
			var t0 = cuts[cut_index]
			var t1 = cuts[cut_index + 1]
			if t1 - t0 <= 0.0001:
				continue
			var midpoint = (t0 + t1) * 0.5
			var midpoint_position = start + edge_vector * midpoint
			if midpoint_position.distance_to(player_position) >= min_distance:
				var segment_length = edge_length * (t1 - t0)
				valid_segments.append([start, edge_vector, t0, t1, segment_length])
				total_length += segment_length

	# 按固定顺序沿合法区域轮换，不再用随机点碰运气。
	if not valid_segments.is_empty():
		var distance_on_safe_area = fmod(float(spawn_index) * 137.0, total_length)
		spawn_index += 1
		for segment in valid_segments:
			if distance_on_safe_area <= segment[4]:
				var ratio = segment[2] + distance_on_safe_area / segment[4] * (segment[3] - segment[2])
				return segment[0] + segment[1] * ratio
			distance_on_safe_area -= segment[4]

	# 极端情况下没有安全段，就返回距离玩家最远的框内角落。
	var farthest_corner = corners[0]
	var farthest_distance = farthest_corner.distance_to(player_position)
	for corner in corners:
		var corner_distance = corner.distance_to(player_position)
		if corner_distance > farthest_distance:
			farthest_corner = corner
			farthest_distance = corner_distance
	return farthest_corner


func _on_player_hit():
	if not game_active or hit_invulnerable or invulnerability_time_left > 0.0:
		return

	if lives > 1:
		hit_invulnerable = true
		lives -= 1
		$HUD.update_lives(lives)
		$HUD.show_message("失去一条命")
		$Player.show()
		$Player.modulate = Color(1.0, 1.0, 1.0, 0.45)
		$Player.get_node("CollisionShape2D").set_deferred("disabled", true)
		await get_tree().create_timer(1.0, false).timeout
		$Player.start($StartPosition.position)
		$Player.modulate = Color.WHITE
		hit_invulnerable = false
	else:
		game_over()
