extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_button_start_adventure_pressed():
	print("Start battle if it has not started yet")
	$timer_battle_tick.start()
	pass

func _on_button_shop_pressed():
	print("Open up the shop to upgrade dice if the battle has not started yet")
	pass

func _on_button_rig_dice_pressed():
	print("Rig the next battle tick")
	pass

func _on_timer_battle_tick_timeout():
	print("Battle Tick - Roll Dice")
	pass

func _on_battle_speed_pause_pressed():
	print("Battle Speed - Paused")
	$timer_battle_tick.paused = true
	pass

func _on_battle_speed_slow_pressed():
	print("Battle Speed - Slow")
	$timer_battle_tick.paused = false
	$timer_battle_tick.wait_time = 2
	pass

func _on_battle_speed_normal_pressed():
	print("Battle Speed - normal")
	$timer_battle_tick.paused = false
	$timer_battle_tick.wait_time = 1
	pass

func _on_battle_speed_fast_pressed():
	print("Battle Speed - Fast")
	$timer_battle_tick.paused = false
	$timer_battle_tick.wait_time = 0.5
	pass