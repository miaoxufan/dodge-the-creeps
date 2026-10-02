extends CanvasLayer

signal start_game
signal upgrade_selected(choice)
var current_upgrade_choices = []
const LEADERBOARD_PATH = "user://leaderboard.json"
var leaderboard_scores = []
var selected_hero_id = 1
var persistence_enabled = true
var portrait_tween: Tween
var menu_clock = 0.0
var pause_overlay: Control
var pause_was_active := false
var pause_previous_focus: Control

func _process(delta):
	menu_clock += delta
	if $HeroArt.visible:
		$HeroArt/Portrait.position.y = 118 + sin(menu_clock*1.5)*3.0
	var main = get_parent()
	if $StartBackdrop.visible or not "game_active" in main:
		$StatusHint.hide()
		return
	$StatusHint.visible = not main.game_finished
	if main.invulnerability_time_left > 0:
		$StatusHint.text = "守护之光  ·  %.1f 秒" % main.invulnerability_time_left
	elif main.hit_invulnerable:
		$StatusHint.text = "短暂庇护  ·  正在重整脚步"
	elif main.get_node("Player").dash_unlocked:
		var p = main.get_node("Player")
		$StatusHint.text = "SPACE 闪步   %d / %d     ·     WASD 移动" % [p.dash_charges,p.dash_max_charges]
	else:
		$StatusHint.text = "WASD 移动   ·   ESC 暂停   ·   收集蓝色灵石以解锁闪步"

func _ready():
	preload("res://ui_skin.gd").apply(self)
	_build_pause_menu()
	$MessageTimer.one_shot = true
	$MessageTimer.process_mode = Node.PROCESS_MODE_PAUSABLE
	get_viewport().size_changed.connect(_fit_ui)
	_fit_ui()
	load_leaderboard()
	set_start_screen(true)

func _fit_ui():
	var viewport_size = get_viewport().get_visible_rect().size
	var factor = min(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	scale = Vector2.ONE * factor
	offset = (viewport_size - Vector2(1280,720)*factor) * 0.5
	for node in [$StartBackdrop,$ModalDim]:
		node.position = -offset / factor
		node.size = viewport_size / factor
	if is_instance_valid(pause_overlay):
		pause_overlay.get_node("Shade").position = -offset / factor
		pause_overlay.get_node("Shade").size = viewport_size / factor

func _build_pause_menu():
	var skin = preload("res://ui_skin.gd")
	pause_overlay = Control.new()
	pause_overlay.name = "PauseMenu"
	pause_overlay.size = Vector2(1280, 720)
	add_child(pause_overlay)
	var shade = ColorRect.new()
	shade.name = "Shade"
	shade.color = Color(0.08, 0.06, 0.04, 0.72)
	pause_overlay.add_child(shade)
	var panel = Panel.new()
	panel.name = "Panel"
	pause_overlay.add_child(panel)
	skin.place(panel, Rect2(420, 190, 440, 340))
	panel.add_theme_stylebox_override("panel", skin.box(skin.PAPER, skin.GOLD, 12))
	var title = skin.label(panel, "Title", "旅途小憩", Rect2(30, 30, 380, 45), 30, skin.INK)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hint = skin.label(panel, "Hint", "游戏已暂停  ·  ESC 继续", Rect2(30, 85, 380, 30), 18, skin.MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(2):
		var button = Button.new()
		button.name = "Resume" if i == 0 else "Quit"
		button.text = "继续游戏" if i == 0 else "退出游戏"
		panel.add_child(button)
		skin.place(button, Rect2(60, 140 + i * 80, 320, 58))
		skin.button(button, i == 0)
		button.pressed.connect(close_pause_menu if i == 0 else quit_from_pause)
		var other = NodePath("../Quit" if i == 0 else "../Resume")
		button.focus_next = other
		button.focus_previous = other
		button.focus_neighbor_top = other
		button.focus_neighbor_bottom = other
	pause_overlay.hide()

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed and not event.echo:
		if pause_overlay.visible:
			close_pause_menu()
		elif not $StartBackdrop.visible and not get_parent().get("game_finished"):
			open_pause_menu()
		else:
			return
		get_viewport().set_input_as_handled()

func open_pause_menu():
	if pause_overlay.visible or $StartBackdrop.visible or get_parent().get("game_finished"):
		return
	pause_was_active = get_tree().paused
	pause_previous_focus = get_viewport().gui_get_focus_owner()
	get_tree().paused = true
	pause_overlay.show()
	pause_overlay.get_node("Panel/Resume").grab_focus()

func close_pause_menu():
	if not pause_overlay.visible:
		return
	pause_overlay.hide()
	get_tree().paused = pause_was_active
	if is_instance_valid(pause_previous_focus) and pause_previous_focus.is_visible_in_tree():
		pause_previous_focus.grab_focus()
	else:
		get_viewport().gui_release_focus()

func quit_from_pause():
	# Explicit exit ends the current run and preserves its score once.
	var main = get_parent()
	if not main.game_finished:
		record_score(main.score)
		main.game_finished = true
	get_tree().quit()

func set_start_screen(show_start):
	if is_instance_valid(pause_overlay) and pause_overlay.visible:
		close_pause_menu()
	$HeroArt.visible = show_start
	$XPBar.visible = not show_start
	$SkillBar.visible = not show_start
	$ModalDim.hide()
	$Message.position = Vector2(76,137) if show_start else Vector2(140,160)
	$Message.size = Vector2(660,70) if show_start else Vector2(1000,65)
	$Message.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if show_start else HORIZONTAL_ALIGNMENT_CENTER
	$Message.text = "林 间 幸 存 者" if show_start else ""
	$StartBackdrop.visible = show_start
	$GridTop.visible = show_start
	$GridBottom.visible = show_start
	$StartFrame.visible = show_start
	$StartTag.visible = show_start
	$StartHint.visible = show_start
	$HeroSelectLabel.visible = show_start
	$Hero1Button.visible = show_start
	$Hero2Button.visible = show_start
	$Hero3Button.visible = show_start
	$StartButton.visible = show_start
	$LeaderboardButton.visible = show_start
	if not show_start:
		$LeaderboardPanel.hide()
	$StatsPanel.visible = not show_start
	$ScoreLabel.visible = not show_start
	$LevelLabel.visible = not show_start
	$LivesLabel.visible = not show_start
	$SkillLabel.visible = not show_start
	$BattlePortrait.visible = not show_start
	$BattleHeroName.visible = not show_start
	if show_start:
		$MessageTimer.stop()
		$Message.show()
		select_hero(selected_hero_id)

func update_score(score):
	$ScoreLabel.text = "生存积分   %d" % score

func update_skill_points(points, points_to_next_level):
	$SkillBar.value = 100.0 * points / max(1,points_to_next_level)
	$SkillLabel.text = "技能点   %d / %d" % [points, points_to_next_level]

func update_level(level, experience, experience_to_next_level):
	$XPBar.value = 100.0 * experience / max(1,experience_to_next_level)
	$LevelLabel.text = "等级 %d   ·   经验 %d / %d" % [level, experience, experience_to_next_level]

func update_lives(lives):
	$LivesLabel.text = "剩余生命   %d" % lives

func load_leaderboard():
	leaderboard_scores.clear()
	if not FileAccess.file_exists(LEADERBOARD_PATH):
		return
	var file = FileAccess.open(LEADERBOARD_PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if data is Array:
		for value in data:
			if value is int or value is float:
				leaderboard_scores.append(int(value))
	leaderboard_scores.sort()
	leaderboard_scores.reverse()

func save_leaderboard():
	if not persistence_enabled:
		return
	var file = FileAccess.open(LEADERBOARD_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(leaderboard_scores))

func record_score(score):
	leaderboard_scores.append(int(score))
	leaderboard_scores.sort()
	leaderboard_scores.reverse()
	if leaderboard_scores.size() > 10:
		leaderboard_scores = leaderboard_scores.slice(0, 10)
	save_leaderboard()

func refresh_leaderboard():
	if leaderboard_scores.is_empty():
		$LeaderboardPanel/ScoreList.text = "这本手册还没有故事。\n\n踏上旅途，写下你的第一份纪录。"
		return
	var lines = []
	for index in range(leaderboard_scores.size()):
		lines.append("第 %02d 名                 %06d 分" % [index + 1, leaderboard_scores[index]])
	$LeaderboardPanel/ScoreList.text = "\n".join(lines)

func show_upgrade_choices(choices, is_skill_upgrade):
	current_upgrade_choices = choices
	$UpgradePanel/Title.text = "灵石的馈赠" if is_skill_upgrade else "旅途中的成长"
	var buttons = [$UpgradePanel/AttackButton,$UpgradePanel/SpeedButton,$UpgradePanel/BulletButton]
	for i in range(3):
		var b = buttons[i]
		b.text = ""
		var info = upgrade_info(choices[i])
		b.get_node("UpgradeName").text = info[0]
		b.get_node("Description").text = info[1]
		b.get_node("Kind").text = "灵石强化  /  SKILL" if is_skill_upgrade else "旅途成长  /  LEVEL UP"
		b.get_node("Icon").kind = info[2]
		b.get_node("Icon").accent = Color("527e92") if is_skill_upgrade else preload("res://hero_catalog.gd").get_hero(selected_hero_id).color
		b.get_node("Icon").queue_redraw()
		var main = get_parent()
		var boosted = false
		if "next_move_upgrade_multiplier" in main:
			boosted = (choices[i]=="speed" and main.next_move_upgrade_multiplier>1) or (choices[i]=="small" and main.next_shrink_scale<0.85)
			if choices[i]=="multishot":
				boosted = (selected_hero_id==2 and main.next_knife_range_upgrade_multiplier>1) or (selected_hero_id==3 and main.next_flask_radius_multiplier>1)
			if choices[i]=="bullet":
				boosted = main.next_bullet_upgrade_multiplier>1 if selected_hero_id==1 else (main.next_knife_speed_upgrade_multiplier>1 if selected_hero_id==2 else main.next_flask_speed_multiplier>1)
		if boosted:
			b.get_node("Kind").text = "祝福生效  /  本次效果已强化"
			b.get_node("Kind").add_theme_color_override("font_color",Color("527e92"))
		else:
			b.get_node("Kind").add_theme_color_override("font_color",Color("89745b"))
	$ModalDim.show()
	$UpgradePanel.show()
	animate_panel($UpgradePanel)

func animate_panel(panel: Control):
	if panel.has_meta("open_tween"):
		var old = panel.get_meta("open_tween")
		if old.is_valid(): old.kill()
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2.ONE*0.97
	panel.modulate.a = 0.5
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel,"scale",Vector2.ONE,0.18)
	tween.tween_property(panel,"modulate:a",1.0,0.18)
	panel.set_meta("open_tween",tween)

func hide_upgrade_choices():
	$ModalDim.hide()
	$UpgradePanel.hide()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("本次旅途结束")

	await $MessageTimer.timeout

	$Message.text = "回到营地，重新出发。"
	$Message.show()

	await get_tree().create_timer(1.0).timeout

	set_start_screen(true)
	$Message.text = "林 间 幸 存 者"
	$Message.show()
	$StartButton.show()

func _on_start_button_pressed():
	$StartButton.hide()
	set_start_screen(false)
	start_game.emit()

func _on_hero_1_pressed():
	select_hero(1)

func _on_hero_2_pressed():
	select_hero(2)

func select_hero(id: int):
	selected_hero_id = id
	var data = preload("res://hero_catalog.gd").get_hero(id)
	$HeroArt/Portrait.texture = load(data.art)
	$HeroArt/Name.text = data.name
	$HeroArt/Name.add_theme_color_override("font_color",data.color)
	$HeroArt/Loadout.text = data.description
	$BattlePortrait.texture = load(data.art)
	$BattleHeroName.text = data.name
	if is_instance_valid(portrait_tween):
		portrait_tween.kill()
	$HeroArt/Portrait.modulate.a = 0.3
	portrait_tween = create_tween()
	portrait_tween.tween_property($HeroArt/Portrait,"modulate:a",1.0,0.22)
	for i in range(1,4):
		get_node("Hero%dButton" % i).set_pressed_no_signal(i == id)

func get_selected_hero_id():
	return selected_hero_id

func _on_leaderboard_button_pressed():
	$HeroArt.hide()
	$ModalDim.show()
	refresh_leaderboard()
	$StartButton.hide()
	$LeaderboardButton.hide()
	$Message.hide()
	$StartTag.hide()
	$StartHint.hide()
	$HeroSelectLabel.hide()
	$Hero1Button.hide()
	$Hero2Button.hide()
	$Hero3Button.hide()
	$LeaderboardPanel.show()
	animate_panel($LeaderboardPanel)

func _on_leaderboard_close_pressed():
	$HeroArt.show()
	$ModalDim.hide()
	$LeaderboardPanel.hide()
	$Message.text = "林 间 幸 存 者"
	$Message.show()
	$StartTag.show()
	$StartHint.show()
	$HeroSelectLabel.show()
	$Hero1Button.show()
	$Hero2Button.show()
	$Hero3Button.show()
	$StartButton.show()
	$LeaderboardButton.show()

func _on_message_timer_timeout():
	$Message.hide()

func _on_attack_upgrade_pressed():
	$ModalDim.hide()
	$UpgradePanel.hide()
	upgrade_selected.emit(current_upgrade_choices[0])

func _on_speed_upgrade_pressed():
	$ModalDim.hide()
	$UpgradePanel.hide()
	upgrade_selected.emit(current_upgrade_choices[1])

func _on_bullet_upgrade_pressed():
	$ModalDim.hide()
	$UpgradePanel.hide()
	upgrade_selected.emit(current_upgrade_choices[2])

func get_upgrade_text(choice):
	return upgrade_info(choice)[0]

func upgrade_info(choice) -> Array:
	var hero = selected_hero_id
	match choice:
		"multishot":
			if hero == 2: return ["延展刀环", "刀的旋转距离 +45\n与敌人保持更宽的间隔", "knife"]
			if hero == 3: return ["广域配方", "爆炸半径 +22\n一瓶药剂，清理更大范围", "flask"]
			return ["齐射", "正面弹幕 +1\n每次射击多发一枚子弹", "multishot"]
		"bullet":
			if hero == 2: return ["疾风回旋", "刀的转速 +0.8\n让刀锋更快扫过身旁", "knife"]
			if hero == 3: return ["熟练调配", "投掷间隔减少 0.15 秒\n最快每 0.35 秒投掷一次", "flask"]
			return ["疾速弹丸", "子弹飞行速度 +150\n更快命中远处的怪物", "bullet"]
		"speed": return ["轻盈步伐", "移动速度 +50\n穿行于包围之间", "speed"]
		"small": return ["袖珍旅人", "身体与碰撞范围缩至 85%\n更容易从怪群间穿过", "small"]
		"life": return ["不屈之心", "剩余生命 +1\n再给这段旅途一次机会", "life"]
		"skill_multishot":
			if hero == 2: return ["刀环秘术", "下一次「延展刀环」效果 ×2\n只强化下一次对应升级", "skill_knife"]
			if hero == 3: return ["浓缩配方", "下一次「广域配方」效果 ×2\n只强化下一次对应升级", "skill_flask"]
			return ["背向齐射", "身后弹幕 +1\n立即增加一枚反向子弹", "skill_multishot"]
		"skill_knife_count": return ["月刃共鸣", "环绕刀刃 +1\n所有刀刃均匀分布", "skill_knife"]
		"skill_flask_count": return ["追加药剂", "每轮药瓶 +1\n优先投向不同的敌人", "skill_flask"]
		"skill_speed": return ["风行祝福", "下一次「轻盈步伐」效果 ×2\n只强化下一次对应升级", "skill_speed"]
		"skill_bullet":
			if hero == 2: return ["回旋秘术", "下一次「疾风回旋」效果 ×2\n只强化下一次对应升级", "skill_knife"]
			if hero == 3: return ["速炼秘术", "下一次「熟练调配」效果 ×2\n仍受最快投掷间隔限制", "skill_flask"]
			return ["破风祝福", "下一次「疾速弹丸」效果 ×2\n只强化下一次对应升级", "skill_bullet"]
		"skill_small": return ["微光身形", "下一次缩小改为缩至 70%\n碰撞范围同步缩小", "skill_small"]
		"skill_dash": return ["闪步", "解锁空格闪避 / 储存次数 +1\n每 3 秒恢复一次充能", "skill_dash"]
	return ["成长", "获得新的力量", "multishot"]
