extends CanvasLayer

signal start_game
signal upgrade_selected(choice)
var current_upgrade_choices = []
const LEADERBOARD_PATH = "user://leaderboard.json"
var leaderboard_scores = []
var selected_hero_id = 1

func _ready():
	load_leaderboard()
	set_start_screen(true)

func set_start_screen(show_start):
	$StartBackdrop.visible = show_start
	$GridTop.visible = show_start
	$GridBottom.visible = show_start
	$StartFrame.visible = show_start
	$StartTag.visible = show_start
	$StartHint.visible = show_start
	$HeroSelectLabel.visible = show_start
	$Hero1Button.visible = show_start
	$Hero2Button.visible = show_start
	$StartButton.visible = show_start
	$LeaderboardButton.visible = show_start
	if not show_start:
		$LeaderboardPanel.hide()
	$StatsPanel.visible = not show_start
	$ScoreLabel.visible = not show_start
	$LevelLabel.visible = not show_start
	$LivesLabel.visible = not show_start
	$SkillLabel.visible = not show_start

func update_score(score):
	$ScoreLabel.text = "SCORE  %d" % score

func update_skill_points(points, points_to_next_level):
	$SkillLabel.text = "SKILL: %d/%d" % [points, points_to_next_level]

func update_level(level, experience, experience_to_next_level):
	$LevelLabel.text = "LEVEL %d   XP: %d/%d" % [level, experience, experience_to_next_level]

func update_lives(lives):
	$LivesLabel.text = "LIVES: %d" % lives

func load_leaderboard():
	leaderboard_scores.clear()
	if not FileAccess.file_exists(LEADERBOARD_PATH):
		return
	var file = FileAccess.open(LEADERBOARD_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if data is Array:
		for value in data:
			if value is int or value is float:
				leaderboard_scores.append(int(value))
	leaderboard_scores.sort()
	leaderboard_scores.reverse()

func save_leaderboard():
	var file = FileAccess.open(LEADERBOARD_PATH, FileAccess.WRITE)
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
		$LeaderboardPanel/ScoreList.text = "NO RECORDS YET\n\nPLAY A RUN TO SET A SCORE"
		return
	var lines = []
	for index in range(leaderboard_scores.size()):
		lines.append("%02d        %06d" % [index + 1, leaderboard_scores[index]])
	$LeaderboardPanel/ScoreList.text = "\n".join(lines)

func show_upgrade_choices(choices, is_skill_upgrade):
	current_upgrade_choices = choices
	$UpgradePanel/Title.text = "选择技能点升级" if is_skill_upgrade else "选择普通升级"
	$UpgradePanel/AttackButton.text = get_upgrade_text(choices[0])
	$UpgradePanel/SpeedButton.text = get_upgrade_text(choices[1])
	$UpgradePanel/BulletButton.text = get_upgrade_text(choices[2])
	$UpgradePanel.show()

func hide_upgrade_choices():
	$UpgradePanel.hide()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")

	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()

	await get_tree().create_timer(1.0).timeout

	set_start_screen(true)
	$Message.text = "DODGE THE CREEPS"
	$Message.show()
	$StartButton.show()

func _on_start_button_pressed():
	$StartButton.hide()
	set_start_screen(false)
	start_game.emit()

func _on_hero_1_pressed():
	selected_hero_id = 1
	$Hero1Button.button_pressed = true
	$Hero2Button.button_pressed = false

func _on_hero_2_pressed():
	selected_hero_id = 2
	$Hero1Button.button_pressed = false
	$Hero2Button.button_pressed = true

func get_selected_hero_id():
	return selected_hero_id

func _on_leaderboard_button_pressed():
	refresh_leaderboard()
	$StartButton.hide()
	$LeaderboardButton.hide()
	$Message.hide()
	$StartTag.hide()
	$StartHint.hide()
	$HeroSelectLabel.hide()
	$Hero1Button.hide()
	$Hero2Button.hide()
	$LeaderboardPanel.show()

func _on_leaderboard_close_pressed():
	$LeaderboardPanel.hide()
	$Message.text = "DODGE THE CREEPS"
	$Message.show()
	$StartTag.show()
	$StartHint.show()
	$HeroSelectLabel.show()
	$Hero1Button.show()
	$Hero2Button.show()
	$StartButton.show()
	$LeaderboardButton.show()

func _on_message_timer_timeout():
	$Message.hide()

func _on_attack_upgrade_pressed():
	$UpgradePanel.hide()
	upgrade_selected.emit(current_upgrade_choices[0])

func _on_speed_upgrade_pressed():
	$UpgradePanel.hide()
	upgrade_selected.emit(current_upgrade_choices[1])

func _on_bullet_upgrade_pressed():
	$UpgradePanel.hide()
	upgrade_selected.emit(current_upgrade_choices[2])

func get_upgrade_text(choice):
	match choice:
		"skill_multishot":
			return "技能：刀距离升级翻倍" if selected_hero_id == 2 else "技能：从身后增加一条子弹"
		"skill_knife_count":
			return "技能：增加一把刀"
		"skill_speed":
			return "技能：移动升级翻倍"
		"skill_bullet":
			return "技能：刀旋转速度翻倍" if selected_hero_id == 2 else "技能：子弹速度升级翻倍"
		"skill_small":
			return "技能：缩小效果强化"
		"skill_dash":
			return "技能：闪避/增加次数"
		"multishot":
			return "刀的距离增加" if selected_hero_id == 2 else "多一条子弹"
		"speed":
			return "移动速度提升"
		"bullet":
			return "刀旋转速度提升" if selected_hero_id == 2 else "子弹速度提升"
		"small":
			return "身体变小"
		"life":
			return "多一条命"
	return "升级"
