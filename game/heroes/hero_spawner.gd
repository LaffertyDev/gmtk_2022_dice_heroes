extends Node2D

func _ready():
	add_to_group("hero_spawners")

func has_hero():
	return get_children().size() > 0

func spawn_hero(hero):
	var hero_res = load("res://game/heroes/hero.tscn")
	var hero_ins = hero_res.instance()
	hero_ins.hero_ability = hero.hero_ability
	hero_ins.hero_type = hero.hero_type
	add_child(hero_ins)