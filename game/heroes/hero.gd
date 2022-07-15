extends Node2D

func _ready():
	add_to_group("heroes")

func roll_dice():
	return randi()%6 + 1