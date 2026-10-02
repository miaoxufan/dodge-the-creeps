extends Area2D

var owner_player: Node2D
var rotation_speed = 5.5
var orbit_radius = 0.0
var skill_orb_scene = preload("res://skill_orb.tscn")

func _ready():
	for node_name in ["Glow", "Blade", "Edge", "Handle"]:
		get_node(node_name).hide()
	queue_redraw()

func _draw():
	# Ivory curved blade, ink outline, brass guard and leather hilt.
	var blade = PackedVector2Array([Vector2(42,-8),Vector2(83,-12),Vector2(115,-24),Vector2(106,3),Vector2(82,12),Vector2(42,8)])
	draw_colored_polygon(blade,Color("eee2ca"))
	var outline = blade.duplicate()
	outline.append(blade[0])
	draw_polyline(outline,Color("382f3e"),3,true)
	draw_line(Vector2(49,3),Vector2(99,-4),Color("b4a6c3"),3,true)
	draw_line(Vector2(12,0),Vector2(40,0),Color("382f3e"),12,true)
	draw_line(Vector2(14,0),Vector2(39,0),Color("a47559"),7,true)
	draw_line(Vector2(42,-15),Vector2(42,15),Color("dbb66c"),5,true)

func setup(player, angle_offset = 0.0, speed = 5.5, radius = 0.0):
	owner_player = player
	rotation = angle_offset
	rotation_speed = speed
	orbit_radius = radius
	global_position = player.global_position

func _process(delta):
	rotation += rotation_speed * delta
	if is_instance_valid(owner_player):
		global_position = owner_player.global_position + Vector2.RIGHT.rotated(rotation) * orbit_radius

func _on_body_entered(body):
	if not body.is_in_group("mobs"):
		return

	body.defeat()
