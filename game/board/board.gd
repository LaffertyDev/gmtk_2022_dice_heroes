extends Node2D

signal new_zone_entered(new_battle)
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
		emit_signal("new_zone_entered", _get_next_battle())

func _get_next_battle():
	var enemies = []
	var rewards = []
	var gold_income = 0
	var enemy_group_health = 1
	match hero_current_position:
		0:
			pass
		1:
			enemies.append({"enemy_type": "slime"}) # 1.5
			gold_income = 1
			enemy_group_health = 1
		2:
			enemies.append({"enemy_type": "bandit"}) # 2.5
			gold_income = 1
			enemy_group_health = 1
		3:
			enemies.append({"enemy_type": "slime"}) # 3
			enemies.append({"enemy_type": "slime"})
			gold_income = 1
			enemy_group_health = 1
		4:
			enemies.append({"enemy_type": "mimic"}) # 3.5
			gold_income = 1
			enemy_group_health = 1
		5:
			enemies.append({"enemy_type": "bandit"}) # 4
			enemies.append({"enemy_type": "slime"})
			gold_income = 1
			enemy_group_health = 1
		6:
			enemies.append({"enemy_type": "slime"}) # 4.5
			enemies.append({"enemy_type": "slime"})
			enemies.append({"enemy_type": "slime"})
			gold_income = 1
			enemy_group_health = 1
		7:
			enemies.append({"enemy_type": "mimic"}) # 5
			enemies.append({"enemy_type": "mimic"})
			gold_income = 1
			enemy_group_health = 1
		8:
			enemies.append({"enemy_type": "bandit"}) # 6
			enemies.append({"enemy_type": "mimic"})
			gold_income = 1
			enemy_group_health = 1
		9:
			enemies.append({"enemy_type": "bandit"}) # 7
			enemies.append({"enemy_type": "bandit"})
			gold_income = 1
		10:
			enemies.append({"enemy_type": "necromancer"}) # 10.5
			enemies.append({"enemy_type": "bandit"})
			enemies.append({"enemy_type": "bandit"})
			gold_income = 1
			enemy_group_health = 1
		11:
			enemies.append({"enemy_type": "bandit"}) # 10
			enemies.append({"enemy_type": "bandit"})
			enemies.append({"enemy_type": "bandit"})
			enemies.append({"enemy_type": "bandit"})
			gold_income = 1
			enemy_group_health = 1
		12:
			enemies.append({"enemy_type": "mimic"}) # 12
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "slime"})
			gold_income = 1
			enemy_group_health = 1
		13:
			enemies.append({"enemy_type": "necromancer"}) # 14
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "bandit"})
			enemies.append({"enemy_type": "bandit"})
			gold_income = 1
			enemy_group_health = 1
		14:
			enemies.append({"enemy_type": "necromancer"}) # 16
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "mimic"})
			gold_income = 1
			enemy_group_health = 1
		15:
			enemies.append({"enemy_type": "dragon"}) # 17
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "mimic"})
			gold_income = 1
			enemy_group_health = 1
		16:
			enemies.append({"enemy_type": "dragon"})  # 19
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "mimic"})
			gold_income = 1
			enemy_group_health = 1
		17:
			enemies.append({"enemy_type": "dragon"}) # 20
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "necromancer"})
			gold_income = 1
			enemy_group_health = 1
		18:
			enemies.append({"enemy_type": "dragon"}) # 21
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "necromancer"})
			gold_income = 1
			enemy_group_health = 1
		19:
			enemies.append({"enemy_type": "dragon"}) # 23
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "mimic"})
			gold_income = 1
			enemy_group_health = 1
		20:
			enemies.append({"enemy_type": "dragon"}) # 26
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			gold_income = 1
			enemy_group_health = 1
		21:
			enemies.append({"enemy_type": "boss"}) # 30
			enemies.append({"enemy_type": "dragon"}) 
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			gold_income = 1
			enemy_group_health = 1
		_:
			pass

	var battle = {"enemies": enemies, "rewards": rewards, "gold_income": gold_income, "enemy_group_health": enemy_group_health}
	return battle
