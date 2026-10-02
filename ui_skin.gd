extends RefCounted

const PAPER = Color("f8ecd3")
const INK = Color("3d302b")
const MUTED = Color("89745b")
const GOLD = Color("bc8d45")
const RED = Color("a74f39")
const CATALOG = preload("res://hero_catalog.gd")

static func box(color: Color, border: Color, radius: int = 10) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0.18,0.12,0.08,0.22)
	s.shadow_size = 2
	s.shadow_offset = Vector2(0,4)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s

static func place(node: Control, rect: Rect2):
	node.position = rect.position
	node.size = rect.size

static func label(parent: Node, node_name: String, text: String, rect: Rect2, font_size: int, color: Color) -> Label:
	var l = Label.new()
	l.name = node_name
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	place(l,rect)
	return l

static func texture(parent: Node, node_name: String, path: String, rect: Rect2) -> TextureRect:
	var t = TextureRect.new()
	t.name = node_name
	t.texture = load(path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	parent.add_child(t)
	place(t,rect)
	return t

static func button(b: Button, primary: bool = false, accent: Color = GOLD):
	b.add_theme_stylebox_override("normal",box(RED if primary else PAPER, Color("733d2e") if primary else Color("b29a73"),8))
	b.add_theme_stylebox_override("hover",box(Color("c86a46") if primary else Color("fff5df"),accent,8))
	b.add_theme_stylebox_override("pressed",box(Color("8e4534") if primary else Color("ead7b6"),accent,8))
	b.add_theme_stylebox_override("hover_pressed",box(Color("8e4534") if primary else Color("f3dfbb"),accent,8))
	var focus = box(Color.TRANSPARENT,accent.lightened(0.2),8)
	focus.shadow_size = 0
	b.add_theme_stylebox_override("focus",focus)
	for state in ["font_color","font_hover_color","font_pressed_color","font_hover_pressed_color"]:
		b.add_theme_color_override(state,PAPER if primary else INK)
	b.add_theme_font_size_override("font_size",20)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if not b.has_meta("hover_motion"):
		b.set_meta("hover_motion",true)
		b.mouse_entered.connect(func(): animate_hover(b,true))
		b.mouse_exited.connect(func(): animate_hover(b,false))

static func animate_hover(b: Button, hovered: bool):
	if b.has_meta("hover_tween"):
		var old = b.get_meta("hover_tween")
		if old.is_valid(): old.kill()
	b.pivot_offset = b.size * 0.5
	var tween = b.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(b,"scale",Vector2.ONE * (1.025 if hovered else 1.0),0.12)
	b.set_meta("hover_tween",tween)

static func apply(h: CanvasLayer):
	h.get_node("Background").hide()
	var backdrop = h.get_node("StartBackdrop")
	backdrop.material = null
	backdrop.texture = load("res://art/menu-desk.png")
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	place(backdrop,Rect2(0,0,1280,720))
	place(h.get_node("StartFrame"),Rect2(36,34,1208,650))
	var frame = box(Color(0.98,0.93,0.82,0.88),Color(0.53,0.4,0.26,0.7),12)
	frame.shadow_size = 0
	h.get_node("StartFrame").add_theme_stylebox_override("panel",frame)
	for line in ["GridTop","GridBottom"]:
		h.get_node(line).color = Color(0.5,0.37,0.22,0.35)
	place(h.get_node("GridTop"),Rect2(72,99,1136,1))
	place(h.get_node("GridBottom"),Rect2(72,627,1136,1))
	place(h.get_node("StartTag"),Rect2(76,54,1100,30))
	h.get_node("StartTag").text = "THE LITTLE SURVIVORS   /   冒险者手册                                      VOL. 01    ·    林间试炼"
	h.get_node("StartTag").horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	h.get_node("StartTag").add_theme_color_override("font_color",MUTED)
	place(h.get_node("StartHint"),Rect2(76,642,1100,24))
	h.get_node("StartHint").text = "W A S D  移动     ·     自动攻击     ·     SPACE  闪避（升级解锁）                     每一次出发，都是新的故事。"
	h.get_node("StartHint").horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	h.get_node("StartHint").add_theme_color_override("font_color",MUTED)
	place(h.get_node("HeroSelectLabel"),Rect2(76,304,620,28))
	h.get_node("HeroSelectLabel").text = "选择同行的冒险者   /   CHOOSE YOUR HERO"
	h.get_node("HeroSelectLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	h.get_node("HeroSelectLabel").add_theme_color_override("font_color",MUTED)
	var third = Button.new()
	third.name = "Hero3Button"
	third.toggle_mode = true
	h.add_child(third)
	third.pressed.connect(h.select_hero.bind(3))
	for i in range(3):
		var data = CATALOG.get_hero(i+1)
		var b = h.get_node("Hero%dButton" % (i+1))
		place(b,Rect2(76+i*206,348,194,164))
		button(b,false,data.color)
		b.text = ""
		texture(b,"Portrait",data.art,Rect2(8,7,97,105))
		label(b,"Number","0%d" % (i+1),Rect2(135,16,45,28),23,data.color)
		label(b,"HeroName",data.name,Rect2(14,112,166,28),20,INK)
		label(b,"Role",data.role,Rect2(14,141,168,18),12,MUTED)
	place(h.get_node("StartButton"),Rect2(76,545,300,59))
	h.get_node("StartButton").text = "踏 上  旅 途    →"
	button(h.get_node("StartButton"),true)
	place(h.get_node("LeaderboardButton"),Rect2(394,545,288,59))
	h.get_node("LeaderboardButton").text = "冒险记录"
	button(h.get_node("LeaderboardButton"))
	var art = Control.new()
	art.name = "HeroArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(art)
	texture(art,"Portrait",CATALOG.get_hero(1).art,Rect2(765,118,405,400))
	label(art,"Name","烬羽射手",Rect2(790,520,355,40),30,RED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label(art,"Loadout","沿移动方向自动射击。\n拉开距离，让弹幕替你开路。",Rect2(752,566,420,48),16,INK).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label(art,"Subtitle","一小步出发，一大群怪物。\n收集、成长，写下你的生存纪录。",Rect2(78,232,620,53),18,MUTED)
	var msg = h.get_node("Message")
	msg.add_theme_constant_override("outline_size",0)
	msg.add_theme_font_size_override("font_size",46)
	msg.add_theme_color_override("font_color",INK)
	place(h.get_node("StatsPanel"),Rect2(20,14,1240,70))
	h.get_node("StatsPanel").add_theme_stylebox_override("panel",box(Color(0.975,0.925,0.82,0.97),Color("967b56"),8))
	var names = ["ScoreLabel","LevelLabel","SkillLabel","LivesLabel"]
	for i in range(names.size()):
		place(h.get_node(names[i]),Rect2(42+i*300,22,282,32))
		h.get_node(names[i]).add_theme_font_size_override("font_size",18)
		h.get_node(names[i]).add_theme_color_override("font_color",INK)
	texture(h,"BattlePortrait",CATALOG.get_hero(1).art,Rect2(28,17,57,61))
	place(h.get_node("ScoreLabel"),Rect2(100,22,230,30))
	label(h,"BattleHeroName","烬羽射手",Rect2(100,55,220,20),12,MUTED)
	var status = label(h,"StatusHint","",Rect2(340,678,600,26),14,Color("fff4d5"))
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_color_override("font_outline_color",Color("454534"))
	status.add_theme_constant_override("outline_size",5)
	status.hide()
	for spec in [["XPBar",342,Color("ba7743")],["SkillBar",642,Color("5299b8")]]:
		var bar = ProgressBar.new()
		bar.name = spec[0]
		bar.show_percentage = false
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_theme_stylebox_override("background",box(Color("d8c9ad"),Color.TRANSPARENT,3))
		bar.add_theme_stylebox_override("fill",box(spec[2],Color.TRANSPARENT,3))
		h.add_child(bar)
		place(bar,Rect2(spec[1],62,265,7))
	var panel = h.get_node("UpgradePanel")
	place(panel,Rect2(126,108,1028,505))
	panel.add_theme_stylebox_override("panel",box(PAPER,Color("8b6e4c"),12))
	panel.get_node("Title").add_theme_color_override("font_color",INK)
	panel.get_node("Title").add_theme_font_size_override("font_size",30)
	place(panel.get_node("Title"),Rect2(32,22,964,46))
	label(panel,"Hint","时光暂歇 · 选择一份馈赠，继续旅程",Rect2(32,73,964,26),16,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(3):
		var b = panel.get_node(["AttackButton","SpeedButton","BulletButton"][i])
		place(b,Rect2(32+i*328,124,308,330))
		button(b)
		b.text = ""
		var icon = preload("res://upgrade_icon.gd").new()
		icon.name = "Icon"
		icon.position = Vector2(154,81)
		b.add_child(icon)
		label(b,"Kind","成长馈赠",Rect2(18,16,272,22),12,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label(b,"UpgradeName","",Rect2(14,139,280,32),23,INK).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var desc = label(b,"Description","",Rect2(22,183,264,84),16,MUTED)
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label(b,"Choose","选择这份馈赠  →",Rect2(16,282,276,26),15,RED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label(panel,"PauseNote","选择期间游戏暂停  ·  完成选择后获得 1 秒保护",Rect2(32,469,964,24),13,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var board = h.get_node("LeaderboardPanel")
	place(board,Rect2(320,75,640,570))
	board.add_theme_stylebox_override("panel",box(PAPER,Color("8b6e4c"),12))
	board.get_node("Title").add_theme_color_override("font_color",INK)
	board.get_node("ScoreList").add_theme_color_override("font_color",INK)
	place(board.get_node("Title"),Rect2(32,26,576,46))
	board.get_node("Title").text = "冒险者名录"
	label(board,"Subtitle","BEST RUNS   /   最高十次生存纪录",Rect2(32,78,576,28),14,MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	place(board.get_node("ScoreList"),Rect2(48,131,544,320))
	board.get_node("ScoreList").add_theme_font_size_override("font_size",19)
	board.get_node("ScoreList").add_theme_constant_override("line_spacing",4)
	place(board.get_node("CloseButton"),Rect2(180,492,280,48))
	board.get_node("CloseButton").text = "返回营地"
	button(board.get_node("CloseButton"))
	var dim = ColorRect.new()
	dim.name = "ModalDim"
	dim.color = Color(0.16,0.12,0.09,0.76)
	dim.size = Vector2(1280,720)
	dim.hide()
	h.add_child(dim)
	h.move_child(board,h.get_child_count()-1)
	h.move_child(panel,h.get_child_count()-1)
