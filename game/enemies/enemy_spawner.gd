extends Node2D

func _ready():
	add_to_group("enemy_spawners")

func has_enemy():
	return get_children().size() > 0

func spawn_enemy(enemy):
	var enemy_res = load("res://game/enemies/enemy.tscn")
	add_child(enemy_res.instance())