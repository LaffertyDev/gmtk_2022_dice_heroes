extends Node2D

var hero_life_total = 0
var enemy_life_total = 0
var available_gold = 15
var is_adventure_started = false

var available_characters = []

signal battle_finished(did_heroes_win)
signal heroes_health_change(health)

func _ready():
	randomize()
	available_characters.append({"name": "Jackson", "hero_type": "jackson", "sprite_name": "hero_jackson.png", "cost": 10, "is_purchased": false})
	available_characters.append({"name": "Lilly", "hero_type": "lilly","sprite_name": "hero_lilly.png", "cost": 10, "is_purchased": false})
	available_characters.append({"name": "Leah", "hero_type": "leah","sprite_name": "hero_leah.png", "cost": 10, "is_purchased": false})
	var _ig = self.connect("battle_finished", $board, "_on_battle_finished")
	var _ig2 = self.connect("heroes_health_change", $board, "_on_heroes_health_changed")
	var _ig3 = $character_shop.connect("purchased_dice", $dice_tray, "_on_new_dice_purchased")
	_hide_battle_state()
	_set_available_gold(available_gold)
	_set_hero_life_total(10)
	_set_enemy_life_total(1)

func _on_button_start_adventure_pressed():
	$timer_battle_tick.start()
	is_adventure_started = true
	_set_hero_life_total(10)
	_set_enemy_life_total(3)
	_show_battle_state()
	emit_signal("battle_finished", true)

func _on_button_shop_pressed():
	$character_shop.popup_centered_ratio(1.0)
	print("Open up the shop to upgrade dice if the battle has not started yet")
	pass

func show_dice_shop(dice):
	$dice_shop.reveal_with_dice(dice)

func _on_button_ability_hurry_pressed():
	if ($button_ability_hurry.pressed):
		$timer_battle_tick.wait_time = 0.25
	else:
		$timer_battle_tick.wait_time = 1

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

func _set_hero_damage(damage):
	$hero_damage_sum.text = str(damage)

func _set_enemy_damage(damage):
	$enemy_damage_sum.text = str(damage)

func _set_hero_life_total(health):
	hero_life_total = health
	$hero_life_total.text = str(hero_life_total)
	emit_signal("heroes_health_change", hero_life_total)

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
	emit_signal("battle_finished", false)
	$timer_battle_tick.stop()
	is_adventure_started = false
	_hide_battle_state()

func _handle_enemies_died():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.get_parent().remove_child(enemy)
		enemy.queue_free()
	_set_available_gold(available_gold + enemies.size())
	$timer_battle_tick.stop()
	emit_signal("battle_finished", true)

func _show_battle_state():
	$enemy_life_total.show()
	$button_start_adventure.hide()
	$damage_indicator.show()
	$hero_damage_sum.show()
	$enemy_damage_sum.show()
	$button_shop.hide()
	$button_ability_hurry.show()
	$dice_tray.hide()
	var heroes_dices = get_tree().get_nodes_in_group("heroes_dice")
	for heroes_dice in heroes_dices:
		if !heroes_dice.is_in_play:
			heroes_dice.hide()

func _hide_battle_state():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.get_parent().remove_child(enemy)
		enemy.queue_free()
	$enemy_life_total.hide()
	$damage_indicator.hide()
	$hero_damage_sum.hide()
	$enemy_damage_sum.hide()
	$button_start_adventure.show()
	$button_ability_hurry.hide()
	$button_shop.show()
	$dice_tray.show()
	var heroes_dices = get_tree().get_nodes_in_group("heroes_dice")
	for heroes_dice in heroes_dices:
		if !heroes_dice.is_in_play:
			heroes_dice.show()

func _on_dice_shop_upgraded_dice(_upgraded_dice, cost):
	_set_available_gold(available_gold - cost)

func _on_character_shop_purchased_dice(purchased_dice):
	_set_available_gold(available_gold - purchased_dice.cost)

func _on_character_shop_purchased_hero(characterObj):
	_set_available_gold(available_gold - characterObj.cost)
	var hero = load("res://game/heroes/hero.tscn")
	var hero_ins = hero.instance()
	hero_ins.hero_type = characterObj.hero_type
	var next_spawn_location = _get_next_hero_spawn_location()
	if (next_spawn_location != null):
		next_spawn_location.add_child(hero_ins)

func _get_next_dice_spawn_location():
	return Vector2(64, 24)

func _get_next_hero_spawn_location():
	var spawn_locations = []
	for child in self.get_children():
		if child.name.begins_with("hero_spawn_"):
			spawn_locations.append({"index": child.name.substr(child.name.length() - 1), "has_hero": child.get_children().size() > 0, "node": child})

	for spawn_location in spawn_locations:
		if (!spawn_location.has_hero):
			return spawn_location.node

func _on_board_new_zone_entered(battle):
	var index = 0
	var spawners = get_tree().get_nodes_in_group("enemy_spawners")
	for spawner in spawners:
		if (index < battle.enemies.size()):
			spawner.spawn_enemy(battle.enemies[index])
			index += 1
	_set_enemy_life_total(battle.enemy_group_health)
	$timer_battle_tick.start()

func _on_board_final_zone_completed():
	print("Final Board Completed")
	_hide_battle_state()
	$victory_dialog.popup_centered_ratio(0.5)
