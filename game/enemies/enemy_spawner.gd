extends Node2D

func _ready():
	add_to_group("enemy_spawners")

func has_enemy():
	return get_children().size() > 0

func spawn_enemy(enemy):
	var enemy_res = load("res://game/enemies/enemy.tscn")
	var ins = enemy_res.instance()
	ins.enemy_type = enemy.enemy_type
	ins.enemy_ability = enemy.ability
	ins.dice_min = enemy.dice_min
	ins.dice_max = enemy.dice_max
	add_child(ins)
