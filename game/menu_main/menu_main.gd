extends Control

onready var global_audio = get_node("/root/global_audio")

func _on_button_start_game_pressed():
	global_audio.play_ui()
	var _ig = get_tree().change_scene("res://game/cinematics/cinematic_intro.tscn")
