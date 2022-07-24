extends Node2D

signal entered_start_zone()
signal new_zone_entered(new_battle)
signal final_zone_completed()
var heroes_won_last_match = false
var hero_current_position = 0
var board_round = 0

onready var global_audio = get_node("/root/global_audio")

func _on_battle_finished(did_heroes_win):
	if did_heroes_win:
		if hero_current_position == 21:
			emit_signal("final_zone_completed")
			board_round += 1
			hero_current_position = 0 # reset so you can loop
			heroes_won_last_match = true
			_move_heroes_to_position()
		else:
			hero_current_position += 1
			heroes_won_last_match = true
			_move_heroes_to_position()
	else:
		_move_heroes_to_position()
		heroes_won_last_match = false

func _get_next_board_position():
	var sprite_origin = Vector2(8,8)
	if (hero_current_position == 0):
		return sprite_origin # board start
	elif (hero_current_position <= 8):
		return sprite_origin + Vector2(hero_current_position * 48, 0)
	elif (hero_current_position <= 11):
		# move down
		return sprite_origin + Vector2(384, 0) + Vector2(0, (hero_current_position - 8) * 48)
	elif (hero_current_position <= 19):
		# move left
		return sprite_origin + Vector2(384, 144) - Vector2((hero_current_position - 11) * 48, 0)
	else:
		# move up
		return sprite_origin + Vector2(0, 144) - Vector2(0, (hero_current_position - 19) * 48)

func _move_heroes_to_position():
	var speed = 0.5
	if !heroes_won_last_match:
		speed = 0.2
	$sprite_tile_indicator.position = _get_next_board_position() - Vector2(8,8)
	$hero_battle_tweener.interpolate_property($hero_on_the_board, "position", $hero_on_the_board.position, _get_next_board_position(), speed, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$hero_battle_tweener.start()
	global_audio.call_deferred("play_walking")

func _on_hero_battle_tweener_tween_all_completed():
	if !heroes_won_last_match && hero_current_position > 0:
		hero_current_position -= 1
		# don't stop audio if we're just going to be moving again
		_move_heroes_to_position()
	elif heroes_won_last_match && hero_current_position > 0:
		global_audio.stop_walking()
		$zone_entered_delay.start()
	else:
		global_audio.stop_walking()
		emit_signal("entered_start_zone")

func _on_zone_entered_delay_timeout():
	if heroes_won_last_match:
		emit_signal("new_zone_entered", _get_next_battle())

func _get_next_battle():
	var enemies = []
	var rewards = []
	var gold_income = 0
	var enemy_group_health = 1
	var board_index = board_round * 21 + hero_current_position
	match board_index:
		0:
			pass
		1:
			enemies.append({"enemy_type": "slime"}) # 1.5
			gold_income = 5
			enemy_group_health = 5
		2:
			enemies.append({"enemy_type": "slime"}) # 1.5
			gold_income = 5
			enemy_group_health = 6
		3:
			enemies.append({"enemy_type": "slime"}) # 3
			enemies.append({"enemy_type": "slime"})
			gold_income = 5
			enemy_group_health = 7
		4:
			enemies.append({"enemy_type": "mimic"}) # 3.5
			gold_income = 5
			enemy_group_health = 8
		5:
			enemies.append({"enemy_type": "bandit"}) # 4
			enemies.append({"enemy_type": "slime"})
			gold_income = 5
			enemy_group_health = 9
		6:
			enemies.append({"enemy_type": "slime"}) # 4.5
			enemies.append({"enemy_type": "slime"})
			enemies.append({"enemy_type": "slime"})
			gold_income = 5
			enemy_group_health = 10
		7:
			enemies.append({"enemy_type": "mimic"}) # 5
			enemies.append({"enemy_type": "mimic"})
			gold_income = 5
			enemy_group_health = 11
		8:
			enemies.append({"enemy_type": "bandit"}) # 6
			enemies.append({"enemy_type": "mimic"})
			gold_income = 5
			enemy_group_health = 12
		9:
			enemies.append({"enemy_type": "bandit"}) # 7
			enemies.append({"enemy_type": "bandit"})
			gold_income = 5
			enemy_group_health = 13
		10:
			enemies.append({"enemy_type": "necromancer"}) # 10.5
			enemies.append({"enemy_type": "bandit"})
			enemies.append({"enemy_type": "bandit"})
			gold_income = 10
			enemy_group_health = 20
		11:
			enemies.append({"enemy_type": "bandit"}) # 10
			enemies.append({"enemy_type": "bandit"})
			enemies.append({"enemy_type": "bandit"})
			enemies.append({"enemy_type": "bandit"})
			gold_income = 10
			enemy_group_health = 20
		12:
			enemies.append({"enemy_type": "mimic"}) # 12
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "slime"})
			gold_income = 10
			enemy_group_health = 25
		13:
			enemies.append({"enemy_type": "necromancer"}) # 14
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "bandit"})
			enemies.append({"enemy_type": "bandit"})
			gold_income = 10
			enemy_group_health = 30
		14:
			enemies.append({"enemy_type": "necromancer"}) # 16 - heal meme
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "mimic"})
			gold_income = 10
			enemy_group_health = 40
		15:
			enemies.append({"enemy_type": "dragon"}) # 17
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "mimic"})
			enemies.append({"enemy_type": "mimic"})
			gold_income = 10
			enemy_group_health = 50
		16:
			enemies.append({"enemy_type": "dragon"})  # 19
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "mimic"})
			gold_income = 10
			enemy_group_health = 50
		17:
			enemies.append({"enemy_type": "dragon"}) # 20
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "necromancer"})
			gold_income = 10
			enemy_group_health = 55
		18:
			enemies.append({"enemy_type": "dragon"}) # 21
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "necromancer"})
			enemies.append({"enemy_type": "necromancer"})
			gold_income = 10
			enemy_group_health = 90
		19:
			enemies.append({"enemy_type": "dragon"}) # 23
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "mimic"})
			gold_income = 10
			enemy_group_health = 115
		20:
			enemies.append({"enemy_type": "dragon"}) # 26
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			gold_income = 10
			enemy_group_health = 150
		21:
			enemies.append({"enemy_type": "boss"}) # 30
			enemies.append({"enemy_type": "dragon"}) 
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			gold_income = 10000
			enemy_group_health = 250
		_:
			enemies.append({"enemy_type": "boss"}) # 30
			enemies.append({"enemy_type": "dragon"}) 
			enemies.append({"enemy_type": "dragon"})
			enemies.append({"enemy_type": "dragon"})
			gold_income = board_index
			enemy_group_health = board_index * 11

	var battle = {"enemies": enemies, "rewards": rewards, "gold_income": gold_income, "enemy_group_health": enemy_group_health}
	return battle
