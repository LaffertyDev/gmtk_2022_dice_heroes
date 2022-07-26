extends Node2D

signal entered_start_zone()
signal new_zone_entered(new_battle)
signal final_zone_completed()
var heroes_won_last_match = false
var hero_current_position = 0
var board_round = 0
var rng = RandomNumberGenerator.new()

onready var global_audio = get_node("/root/global_audio")

func _ready():
	rng.randomize()

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
			enemies.append({"enemy_type": "mimic", "dice_min": 4, "dice_max": 4, "ability": "entangle"}) # 5
			enemies.append({"enemy_type": "mimic", "dice_min": 4, "dice_max": 4, "ability": "entangle"}) # 5
			enemies.append({"enemy_type": "mimic", "dice_min": 4, "dice_max": 4, "ability": "entangle"}) # 5
			enemies.append({"enemy_type": "mimic", "dice_min": 4, "dice_max": 4, "ability": "entangle"}) # 5
			#enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"}) # 1.5
			gold_income = 5
			enemy_group_health = 5000
		2:
			enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"}) # 1.5
			gold_income = 5
			enemy_group_health = 6
		3:
			enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"}) # 3
			enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"})
			gold_income = 5
			enemy_group_health = 7
		4:
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"}) # 3.5
			gold_income = 5
			enemy_group_health = 8
		5:
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"}) # 4
			enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"})
			gold_income = 5
			enemy_group_health = 9
		6:
			enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"}) # 4.5
			enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"})
			enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"})
			gold_income = 5
			enemy_group_health = 10
		7:
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"}) # 5
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			gold_income = 5
			enemy_group_health = 11
		8:
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"}) # 6
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			gold_income = 5
			enemy_group_health = 12
		9:
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"}) # 7
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"})
			gold_income = 5
			enemy_group_health = 13
		10:
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"}) # 10.5
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"})
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"})
			gold_income = 10
			enemy_group_health = 20
		11:
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"}) # 10
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"})
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"})
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"})
			gold_income = 10
			enemy_group_health = 20
		12:
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"}) # 12
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			enemies.append({"enemy_type": "slime", "dice_min": 1, "dice_max": 2, "ability": "damage"})
			gold_income = 10
			enemy_group_health = 25
		13:
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"}) # 14
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"})
			enemies.append({"enemy_type": "bandit", "dice_min": 1, "dice_max": 4, "ability": "damage"})
			gold_income = 10
			enemy_group_health = 30
		14:
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"}) # 16 - heal meme
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			gold_income = 10
			enemy_group_health = 40
		15:
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"}) # 17
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			gold_income = 10
			enemy_group_health = 50
		16:
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})  # 19
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			gold_income = 10
			enemy_group_health = 50
		17:
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"}) # 20
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			gold_income = 10
			enemy_group_health = 55
		18:
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"}) # 21
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			enemies.append({"enemy_type": "necromancer", "dice_min": 1, "dice_max": 8, "ability": "heal"})
			gold_income = 10
			enemy_group_health = 90
		19:
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"}) # 23
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})
			enemies.append({"enemy_type": "mimic", "dice_min": 1, "dice_max": 6, "ability": "entangle"})
			gold_income = 10
			enemy_group_health = 115
		20:
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"}) # 26
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})
			gold_income = 10
			enemy_group_health = 150
		21:
			enemies.append({"enemy_type": "boss", "dice_min": 1, "dice_max": 20, "ability": "damage"}) # 30
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"}) 
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})
			enemies.append({"enemy_type": "dragon", "dice_min": 1, "dice_max": 12, "ability": "damage"})
			gold_income = 96374
			enemy_group_health = 250
		_:
			var dice_min = rng.randi_range(board_index, board_index * 2)
			var dice_max = rng.randi_range(board_round * board_index, board_round * board_index + (20 * board_round))
			while (enemies.size() < 4):
				if (rng.randi_range(0,10) == 0):
					enemies.append({"enemy_type": "mimic", "dice_min": min(board_round, rng.randi_range(board_round, 6)), "dice_max": 6, "ability": "entangle"})
				elif (rng.randi_range(0,5) == 0):
					enemies.append({"enemy_type": "dragon", "dice_min": dice_min, "dice_max": dice_max, "ability": "damage"}) # 30
				elif (rng.randi_range(0,10) == 0):
					enemies.append({"enemy_type": "necromancer", "dice_min": dice_min * 2, "dice_max": dice_max * 2, "ability": "heal"}) # 30

			gold_income = board_index * 2
			enemy_group_health = board_index * 13

	var battle = {"enemies": enemies, "rewards": rewards, "gold_income": gold_income, "enemy_group_health": enemy_group_health}
	return battle
