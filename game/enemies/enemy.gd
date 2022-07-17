extends Node2D

var enemy_type = "bandit"
var enemy_ability = "damage"

func _ready():
	add_to_group("enemies")
	match enemy_type:
		"slime":
			enemy_ability = "damage"
			$Sprite.texture = load("res://game/assets/enemies/enemy_slime.png")
			var dice_res = load("res://game/dice/dice.tscn")
			var dice_ins = dice_res.instance()
			dice_ins.dice_type = "D2"
			dice_ins.name = "dice"
			add_child(dice_ins)
			dice_ins.position.x = -24
		"bandit":
			enemy_ability = "damage"
			$Sprite.texture = load("res://game/assets/enemies/enemy_bandit.png")
			var dice_res = load("res://game/dice/dice.tscn")
			var dice_ins = dice_res.instance()
			dice_ins.dice_type = "D4"
			dice_ins.name = "dice"
			add_child(dice_ins)
			dice_ins.position.x = -24
		"mimic":
			enemy_ability = "entangle"
			$Sprite.texture = load("res://game/assets/enemies/enemy_mimic.png")
			var dice_res = load("res://game/dice/dice.tscn")
			var dice_ins = dice_res.instance()
			dice_ins.dice_type = "D4"
			dice_ins.name = "dice"
			add_child(dice_ins)
			dice_ins.position.x = -24
		"necromancer":
			enemy_ability = "heal"
			$Sprite.texture = load("res://game/assets/enemies/enemy_necromancer.png")
			var dice_res = load("res://game/dice/dice.tscn")
			var dice_ins = dice_res.instance()
			dice_ins.dice_type = "D8"
			dice_ins.name = "dice"
			add_child(dice_ins)
			dice_ins.position.x = -24
		"dragon":
			enemy_ability = "damage"
			$Sprite.texture = load("res://game/assets/enemies/enemy_dragon.png")
			var dice_res = load("res://game/dice/dice.tscn")
			var dice_ins = dice_res.instance()
			dice_ins.dice_type = "D12"
			dice_ins.name = "dice"
			add_child(dice_ins)
			dice_ins.position.x = -24
		"boss":
			enemy_ability = "damage"
			$Sprite.texture = load("res://game/assets/enemies/enemy_boss.png")
			var dice_res = load("res://game/dice/dice.tscn")
			var dice_ins = dice_res.instance()
			dice_ins.dice_type = "D20"
			dice_ins.name = "dice"
			add_child(dice_ins)
			dice_ins.position.x = -24


func roll_dice():
	return $dice.roll_dice()
