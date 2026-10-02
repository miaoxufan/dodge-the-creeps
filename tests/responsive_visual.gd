extends SceneTree

func _initialize():
	call_deferred("run")

func run():
	var hud = load("res://hud.tscn").instantiate()
	root.add_child(hud)
	for size in [Vector2i(1280,800),Vector2i(1920,1080)]:
		root.size = size
		await create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("D:/codex/menu-%dx%d.png" % [size.x,size.y])
		assert(hud.get_node("StartBackdrop").size.x * hud.scale.x >= root.get_visible_rect().size.x-1)
		assert(hud.get_node("ModalDim").size.y * hud.scale.y >= root.get_visible_rect().size.y-1)
	print("RESPONSIVE CHECK PASSED")
	quit()
