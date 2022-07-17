extends Node2D

func play_ui():
	$ui_click_sound.play()

func play_get_money():
	$get_money_sound.play()

func play_open_shop():
	$open_shop_sound.play()

func play_walking():
	if (!$walking_sound.playing):
		$walking_sound.play()

func stop_walking():
	$walking_sound.stop()

func play_dice_place():
	$place_dice_sound.play()

func play_dice_pickup():
	$pickup_dice_sound.play(0.25)

func play_dice_roll():
	$roll_dice_sound.play()

func play_battle_win():
	$battle_win.play()

func play_battle_lose():
	$battle_lose.play()

func play_victory_sound():
	$victory_sound.play()
