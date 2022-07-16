extends Node2D

func _ready():
	add_to_group("enemy_spawners")

func has_enemy():
	return get_children().size() > 0

func spawn_enemy(_enemy):
	var enemy_res = load("res://game/enemies/enemy.tscn")
	var ins = enemy_res.instance()
	ins.enemy_type = _enemy.enemy_type
	add_child(ins)