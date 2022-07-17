extends Node2D

var hero_type = "nameless_hero"
var hero_ability = "damage"

func _ready():
	add_to_group("heroes")
	match hero_type:
		"nameless_hero":
			$Sprite.texture = load("res://game/assets/heroes/main_hero.png")
		"lilly":
			$Sprite.texture = load("res://game/assets/heroes/hero_lilly.png")
		"jackson":
			$Sprite.texture = load("res://game/assets/heroes/hero_jackson.png")
		"leah":
			$Sprite.texture = load("res://game/assets/heroes/hero_leah.png")

func roll_dice():
	if $dice_hero_drop_target.has_dice:
		return $dice_hero_drop_target.slotted_dice.roll_dice()
	else:
		return 0 # no dice, no attack