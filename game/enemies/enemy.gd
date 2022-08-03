extends Node2D

var enemy_type = "bandit"
var enemy_ability = "damage"
var dice_min = 1
var dice_max = 2
var grappled_roll_remaining = 0

func _ready():
	add_to_group("enemies")
	match enemy_type:
		"slime":
			$Sprite.texture = load("res://game/assets/enemies/enemy_slime.png")
		"bandit":
			$Sprite.texture = load("res://game/assets/enemies/enemy_bandit.png")
		"mimic":
			$Sprite.texture = load("res://game/assets/enemies/enemy_mimic.png")
		"necromancer":
			$Sprite.texture = load("res://game/assets/enemies/enemy_necromancer.png")
		"dragon":
			$Sprite.texture = load("res://game/assets/enemies/enemy_dragon.png")
		"boss":
			$Sprite.texture = load("res://game/assets/enemies/enemy_boss.png")

	var dice_res = load("res://game/dice/dice.tscn")
	var dice_ins = dice_res.instance()
	dice_ins.dice_type = "D2"
	dice_ins.set_dice_stats(dice_min, dice_max)
	dice_ins.name = "dice"
	add_child(dice_ins)
	dice_ins.position.x = -24

func set_grappled():
	grappled_roll_remaining = 2
	$Sprite.modulate = Color(0.1, 0.1, 0.1)

func roll_dice():
	if grappled_roll_remaining > 0:
		grappled_roll_remaining -= 1
		if grappled_roll_remaining == 0:
			$Sprite.modulate = Color(1.0, 1.0, 1.0)
			pass
		return 0

	return $dice.roll_dice(enemy_ability)
