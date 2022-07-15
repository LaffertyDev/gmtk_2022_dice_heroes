extends Node2D

func _ready():
	add_to_group("enemies")

func roll_dice():
	return randi()%6 + 1