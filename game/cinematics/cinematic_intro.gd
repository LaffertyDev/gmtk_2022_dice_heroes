extends Control


onready var global_audio = get_node("/root/global_audio")
var current_tutorial = "none"

func _ready():
	_on_tutorial_timer_timeout()

func _on_tutorial_timer_timeout():
	var tutorial_label = get_node("%tutorial_label")
	$tutorial_timer.start() # in case skip was pressed, reset the timer
	match current_tutorial:
		"none":
			current_tutorial = "welcome"
			tutorial_label.text = "Welcome to Dice Heroes!"
		"welcome":
			current_tutorial = "gameplay"
			tutorial_label.text = "Dice Heroes is an Incremental Auto Battler. Delve into the dungeon to get gold, eventually getting deep enough to find the Monstrous Treasure Hoard!"
		"gameplay":
			current_tutorial = "heroes"
			tutorial_label.text = "Heroes automatically fight the monsters in the dungeon. Make sure they have the tools equipped to fight! Each hero has a unique ability."
		"heroes":
			current_tutorial = "dice"
			tutorial_label.text = "Heroes use dice to fight. In battle they will roll your dice you give them. Upgrade dice in your dice shop. Start by assigning a dice to your Hero."
		"dice":
			current_tutorial = "criticals"
			tutorial_label.text = "Dice can critically strike. For some heroes, this means they will use their ability!"
		"criticals":
			tutorial_label.text = "And now, go forth and claim your fortunes!"
			get_node("%button_enter").show()
			get_node("%button_skip").hide()
			$tutorial_timer.stop()

func _on_button_enter_pressed():
	global_audio.play_ui()
	var _ig = get_tree().change_scene("res://game/game.tscn")

func _on_button_skip_pressed():
	_on_tutorial_timer_timeout()