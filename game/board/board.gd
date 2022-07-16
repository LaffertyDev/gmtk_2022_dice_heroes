extends TileMap

signal new_zone_entered(enemies_to_fight)
signal final_zone_completed()
var heroes_won_last_match = false
var hero_current_position = 0

func _on_battle_finished(did_heroes_win):
	print("battle finished")
	if did_heroes_win:
		if hero_current_position == 21:
			emit_signal("final_zone_completed")
		else:
			hero_current_position += 1
			heroes_won_last_match = true
			_move_heroes_to_position()
	else:
		_move_heroes_to_position()
		heroes_won_last_match = false

func _on_heroes_health_changed(health):
	$hero_on_the_board/hero_board_life.text = str(health)

func _get_next_board_position():
	if (hero_current_position == 0):
		return Vector2(16,16) # board start
	elif (hero_current_position <= 8):
		return Vector2(16,16) + Vector2(hero_current_position * 48, 0)
	elif (hero_current_position <= 11):
		# move down
		return Vector2(16,16) + Vector2(384, 0) + Vector2(0, (hero_current_position - 8) * 48)
	elif (hero_current_position <= 19):
		# move left
		return Vector2(16,16) + Vector2(384, 144) - Vector2((hero_current_position - 11) * 48, 0)
	else:
		# move up
		return Vector2(16,16) + Vector2(0, 144) - Vector2(0, (hero_current_position - 19) * 48)

func _move_heroes_to_position():
	var speed = 0.5
	if !heroes_won_last_match:
		speed = 0.2
	$hero_battle_tweener.interpolate_property($hero_on_the_board, "position", $hero_on_the_board.position, _get_next_board_position(), speed, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	$hero_battle_tweener.start()

func _on_hero_battle_tweener_tween_all_completed():
	if !heroes_won_last_match && hero_current_position > 0:
		hero_current_position -= 1
		_move_heroes_to_position()
	elif heroes_won_last_match:
		var enemies = []
		enemies.append({})
		emit_signal("new_zone_entered", enemies)
