extends RefCounted

# Shared identity for selection, in-world art and upgrade descriptions.
const HEROES = {
	1: {"name": "烬羽射手", "role": "游击 · 定向火力", "tag": "THE RANGER", "color": Color("b84e35"), "art": "res://art/heroes/ranger.png", "description": "沿移动方向自动射击。\n拉开距离，让弹幕替你开路。", "weapon": "火铳", "anchor": Vector2(0.57, 0.55)},
	2: {"name": "月影刀客", "role": "近战 · 双刀环绕", "tag": "THE DUELIST", "color": Color("76608b"), "art": "res://art/heroes/duelist.png", "description": "双刀环绕，扫清身旁的怪物。\n扩大刀环，在危险中穿行。", "weapon": "月刃", "anchor": Vector2(0.5, 0.55)},
	3: {"name": "苔灵药师", "role": "炼金 · 范围爆破", "tag": "THE ALCHEMIST", "color": Color("547455"), "art": "res://art/heroes/alchemist.png", "description": "自动向附近敌人投掷药瓶。\n落地爆破，一次清除一簇敌人。", "weapon": "药剂", "anchor": Vector2(0.5, 0.55)}
}

static func get_hero(id: int) -> Dictionary:
	return HEROES.get(id, HEROES[1])
