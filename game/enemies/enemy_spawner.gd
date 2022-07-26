extends Node2D

func _ready():
	add_to_group("enemy_spawners")

func has_enemy():
	return get_children().size() > 0

func spawn_enemy(_enemy):
	var enemy_res = load("res://game/enemies/enemy.tscn")
	var ins = enemy_res.instance()
	ins.enemy_type = _enemy.enemy_type
	ins.enemy_ability = _enemy.ability
	ins.dice_min = _enemy.dice_min
	ins.dice_max = _enemy.dice_max
	add_child(ins)
