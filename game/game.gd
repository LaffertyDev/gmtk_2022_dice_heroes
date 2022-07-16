extends Node2D

var hero_life_total = 0
var enemy_life_total = 0
var available_gold = 10

func _ready():
	randomize()
	_hide_battle_state()
	_set_available_gold(available_gold)
	_set_hero_life_total(10)
	_set_enemy_life_total(0)

func _on_button_start_adventure_pressed():
	$timer_battle_tick.start()
	_set_hero_life_total(10)
	_set_enemy_life_total(10)
	_show_battle_state()

func _on_button_shop_pressed():
	$character_shop.popup_centered_ratio(1.0)
	print("Open up the shop to upgrade dice if the battle has not started yet")
	pass

func _on_button_rig_dice_pressed():
	print("Rig the next battle tick")
	pass

func _on_timer_battle_tick_timeout():
	print("Battle Tick - Roll Dice")
	var heroes = get_tree().get_nodes_in_group("heroes")
	var enemies = get_tree().get_nodes_in_group("enemies")
	var hero_damage_sum = 0
	for hero in heroes:
		hero_damage_sum += hero.roll_dice()
	_set_hero_damage(hero_damage_sum)

	var enemy_damage_sum = 0
	for enemy in enemies:
		enemy_damage_sum += enemy.roll_dice()
	_set_enemy_damage(enemy_damage_sum)

	if hero_damage_sum < enemy_damage_sum:
		_set_hero_life_total(hero_life_total - 1)
		_set_battle_indicator_direction('hero')
	elif hero_damage_sum > enemy_damage_sum:
		_set_enemy_life_total(enemy_life_total - 1)
		_set_battle_indicator_direction('enemy')
	else:
		_set_battle_indicator_direction('draw')

	if hero_life_total == 0:
		_handle_heroes_died()
	elif enemy_life_total == 0:
		_handle_enemies_died()


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

func _set_hero_damage(damage):
	$hero_damage_sum.text = str(damage)

func _set_enemy_damage(damage):
	$enemy_damage_sum.text = str(damage)

func _set_hero_life_total(health):
	hero_life_total = health
	$hero_life_total.text = str(hero_life_total)
	$hero_on_the_board/hero_board_life.text = str(hero_life_total)

func _set_enemy_life_total(health):
	enemy_life_total = health
	$enemy_life_total.text = str(enemy_life_total)

func _set_battle_indicator_direction(direction):
	if (direction == 'hero'):
		$damage_indicator.rotation_degrees = 0
	elif (direction == 'enemy'):
		$damage_indicator.rotation_degrees = 180
	elif (direction == 'draw'):
		$damage_indicator.rotation_degrees = 90

func _set_available_gold(amount):
	available_gold = amount
	$gold_amount.text = "Gold: " + str(amount)

func _handle_heroes_died():
	print("heroes died, reset board and reset round")
	$timer_battle_tick.stop()
	_hide_battle_state()

func _handle_enemies_died():
	print("enemies died, advance heroes to next battle")

func _show_battle_state():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.show()
	$enemy_life_total.show()
	$button_start_adventure.hide()
	$damage_indicator.show()
	$hero_damage_sum.show()
	$enemy_damage_sum.show()

func _hide_battle_state():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.hide()
	$enemy_life_total.hide()
	$damage_indicator.hide()
	$hero_damage_sum.hide()
	$enemy_damage_sum.hide()
	$button_start_adventure.show()

func _on_character_shop_purchased_hero(characterObj):
	print(characterObj.name)
	_set_available_gold(available_gold - characterObj.cost)
	var hero = load("res://game/heroes/hero.tscn")
	var next_spawn_location = _get_next_hero_spawn_location()
	if (next_spawn_location != null):
		next_spawn_location.add_child(hero.instance())

func _get_next_hero_spawn_location():
	var spawn_locations = []
	for child in self.get_children():
		if child.name.begins_with("hero_spawn_"):
			spawn_locations.append({"index": child.name.substr(child.name.length() - 1), "has_hero": child.get_children().size() > 0, "node": child})

	for spawn_location in spawn_locations:
		if (!spawn_location.has_hero):
			return spawn_location.node
