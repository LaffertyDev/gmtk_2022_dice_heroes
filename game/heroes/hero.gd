extends Node2D

func _ready():
	add_to_group("heroes")

func roll_dice():
	if $dice_hero_drop_target.has_dice:
		return $dice_hero_drop_target.slotted_dice.roll_dice()
	else:
		return randi()%2 + 1
