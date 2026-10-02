extends Node2D

var ground = preload("res://art/forest-arena.png")

func _ready():
	z_index = -100
	get_viewport().size_changed.connect(queue_redraw)

func _draw():
	draw_texture_rect(ground, get_viewport_rect(), false)
