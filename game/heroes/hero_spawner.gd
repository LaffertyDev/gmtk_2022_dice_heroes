extends Node2D

func _ready():
	add_to_group("hero_spawners")

func has_hero():
	return get_children().size() > 0

func get_hero():
	if get_children().size() == 0:
		return null

	return get_children()[0]

func spawn_hero(character):
	var hero_res = load("res://game/heroes/hero.tscn")
	var hero_ins = hero_res.instance()
	hero_ins.hero_ability = character.hero_ability
	hero_ins.hero_type = character.hero_type
	character.is_in_play = true
	add_child(hero_ins)

func remove_hero():
	var children = get_children()
	for hero in children:
		hero.clear_dice()
		remove_child(hero)
		hero.queue_free()
