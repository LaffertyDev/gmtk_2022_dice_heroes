extends Node2D

var hero_life_current = 0
var hero_life_max = 10
var enemy_life_current = 0
var enemy_life_max = 10
var available_gold = 999999
var next_gold_reward = 0
var is_adventure_started = false
var current_battle_bleed_stacks = 0
var current_battle_bleed_damage_sum = 0

var available_characters = []

signal battle_finished(did_heroes_win)

onready var global_audio = get_node("/root/global_audio")

func _ready():
	randomize()
	available_characters.append({"name": "Max", "hero_type": "nameless_hero", "hero_ability": "damage", "sprite_name": "main_hero.png", "cost": 0, "is_purchased": true, "is_in_play": true})
	available_characters.append({"name": "Leah", "hero_type": "leah", "hero_ability": "heal", "sprite_name": "hero_leah.png", "cost": 10, "is_purchased": false, "is_in_play": false})
	available_characters.append({"name": "Lilly", "hero_type": "lilly", "hero_ability": "clear", "sprite_name": "hero_lilly.png", "cost": 10, "is_purchased": false, "is_in_play": false})
	available_characters.append({"name": "Bob", "hero_type": "bob", "hero_ability": "grapple", "sprite_name": "hero_bob.png", "cost": 10, "is_purchased": false, "is_in_play": false})
	available_characters.append({"name": "Jackson", "hero_type": "jackson", "hero_ability": "bleed", "sprite_name": "hero_jackson.png", "cost": 10, "is_purchased": false, "is_in_play": false})
	available_characters.append({"name": "Thief", "hero_type": "thief", "hero_ability": "steal", "sprite_name": "hero_thief.png", "cost": 30, "is_purchased": false, "is_in_play": false})

	var _ig = self.connect("battle_finished", $board, "_on_battle_finished")
	var _ig3 = $character_shop.connect("purchased_dice", $dice_tray, "_on_new_dice_purchased")
	_hide_battle_state()
	_set_available_gold(1000)
	_set_hero_life_current(hero_life_max)
	_set_hero_life_max(hero_life_max)
	_set_enemy_life_current(enemy_life_max)
	_set_enemy_life_max(enemy_life_max)
	current_battle_bleed_stacks = 0
	current_battle_bleed_damage_sum = 0

func _on_help_text_delay_timer_timeout():
	$help_text_timer_scanner.start()

func _on_help_text_timer_scanner_timeout():
	var heroes = get_tree().get_nodes_in_group("heroes")
	if !is_adventure_started:
		var all_heroes_no_dice = true
		var some_heroes_have_dice = false
		var some_heroes_have_no_dice = false
		for hero in heroes:
			if hero.has_dice():
				all_heroes_no_dice = false
				some_heroes_have_dice = true
			else:
				some_heroes_have_no_dice = true

		if all_heroes_no_dice:
			$help_label.text = "Assign dice to your Heroes by dragging them from your Dice Tray and then press Start to dive into the dungeon!"
		elif !$dice_tray.has_dice_in_tray() && some_heroes_have_dice && some_heroes_have_no_dice:
			$help_label.text = "Be sure to check your shop"
		else:
			$help_label.text = ""
	else:
		var hero_is_entangled = false
		for hero in heroes:
			hero_is_entangled = hero_is_entangled || hero.is_entangled
		if hero_is_entangled:
			$help_label.text = "Your hero is entangled! Free them by clicking on them."
		else:
			$help_label.text = ""
			$entangle_warning.hide()


func _on_button_start_adventure_pressed():
	global_audio.play_ui()
	current_battle_bleed_stacks = 0
	current_battle_bleed_damage_sum = 0
	_update_bleed()
	is_adventure_started = true
	_set_hero_life_current(hero_life_max)
	_set_enemy_life_current(enemy_life_max)
	_show_battle_state()
	next_gold_reward = 0
	emit_signal("battle_finished", true)

func _on_button_shop_pressed():
	global_audio.play_open_shop()
	$character_shop.popup_centered_ratio(1.0)
	pass

func show_dice_shop(dice):
	global_audio.play_open_shop()
	$dice_shop.reveal_with_dice(dice)

func _on_button_ability_hurry_pressed():
	global_audio.play_ui()
	if ($button_ability_hurry.pressed):
		$timer_battle_tick.wait_time = 0.25
	else:
		$timer_battle_tick.wait_time = 1

func _on_timer_battle_tick_timeout():
	global_audio.play_dice_roll()
	var heroes = get_tree().get_nodes_in_group("heroes")
	var enemies = get_tree().get_nodes_in_group("enemies")
	var hero_damage_sum = 0
	var hero_heal_sum = 0
	var hero_gamble_sum = 0
	var hero_enemies_grappled = 0
	var hero_clear_sum = 0
	for hero in heroes:
		var current_hero_roll = hero.roll_dice()
		match hero.hero_ability:
			"damage":
				hero_damage_sum += current_hero_roll
				if hero.did_crit():
					hero_damage_sum += current_hero_roll * 3
			"bleed":
				hero_damage_sum += current_hero_roll
				if hero.did_crit():
					current_battle_bleed_stacks += 1
					current_battle_bleed_damage_sum = hero.get_hero_dice().maximum - hero.get_hero_dice().minimum
					_update_bleed()
			"clear":
				hero_damage_sum += current_hero_roll
				if hero.did_crit():
					hero_clear_sum += 1
			"heal":
				hero_heal_sum += current_hero_roll
				if hero.did_crit():
					hero_heal_sum += current_hero_roll
			"grapple":
				hero_damage_sum += current_hero_roll
				if hero.did_crit():
					hero_enemies_grappled += 1
			"steal":
				hero_damage_sum += current_hero_roll
				if hero.did_crit():
					hero_gamble_sum += current_hero_roll

	hero_damage_sum += current_battle_bleed_stacks * current_battle_bleed_damage_sum
	var enemy_damage_sum = 0
	var enemy_heal_sum = 0
	var enemy_entangled_count = 0
	for enemy in enemies:
		match(enemy.enemy_ability):
			"damage":
				enemy_damage_sum += enemy.roll_dice()
			"heal":
				enemy_heal_sum += enemy.roll_dice()
			"entangle":
				if enemy.roll_dice() == 4:
					# if enemy rolls a 4, then entangle (25% chance)
					enemy_entangled_count += 1
			_:
				print("Critical Error -- no valid enemy ability type")

	if hero_clear_sum > 0:
		_clear_entangle_by_amount(hero_clear_sum)

	if hero_enemies_grappled > 0:
		for _x in range(hero_enemies_grappled):
			enemies[randi()%enemies.size()].set_grappled()

	if enemy_entangled_count > 0:
		global_audio.play_entanglement()
		for _x in range(enemy_entangled_count):
			$entangle_warning.show()
			heroes[randi()%heroes.size()].set_entangled()

	hero_life_current = max(0, hero_life_current - enemy_damage_sum)
	enemy_life_current = max(0, enemy_life_current - hero_damage_sum)

	_set_available_gold(available_gold + hero_gamble_sum)

	if hero_life_current == 0:
		_handle_heroes_died()
		global_audio.play_battle_lose()
		_set_hero_life_current(hero_life_current)
	elif enemy_life_current == 0:
		_handle_enemies_died()
		global_audio.play_battle_win()

	# heroes can only heal if they have HP, otherwise the health looks weird
	if hero_life_current > 0:
		hero_life_current = min(hero_life_max, hero_life_current + hero_heal_sum)
		_set_hero_life_current(hero_life_current)
		enemy_life_current = min(enemy_life_max, enemy_life_current + enemy_heal_sum)
		_set_enemy_life_current(enemy_life_current)

func _clear_entangle_by_amount(amount):
	var heroes = get_tree().get_nodes_in_group("heroes")
	while (amount > 0):
		amount -= 1
		for hero in heroes:
			if hero.is_hero_entangled():
				hero.clear_entangle()
				break

func _set_hero_life_current(health):
	hero_life_current = health
	$hero_health_bar.value = health
	$hero_health_bar/hero_life_label.text = str(hero_life_current) + " / " + str(hero_life_max)

func _set_hero_life_max(health_max):
	hero_life_max = health_max
	$hero_health_bar.max_value = health_max
	$hero_health_bar/hero_life_label.text = str(hero_life_current) + " / " + str(hero_life_max)

func _set_enemy_life_current(health):
	enemy_life_current = health
	$enemy_health_bar.value = health
	$enemy_health_bar/enemy_life_label.text = str(enemy_life_current) + " / " + str(enemy_life_max)

func _set_enemy_life_max(health_max):
	enemy_life_max = health_max
	$enemy_health_bar.max_value = health_max
	$enemy_health_bar/enemy_life_label.text = str(enemy_life_current) + " / " + str(enemy_life_max)

func _set_available_gold(amount):
	if (available_gold != amount):
		available_gold = amount
		global_audio.play_get_money()
		$gold_amount.text = "Gold: " + str(amount)
		var tween_anim = $gold_amount/gold_tween
		tween_anim.remove_all()
		var gold_coin_anim = $gold_amount/gold_coin_anim
		tween_anim.interpolate_property(gold_coin_anim, "position", Vector2(34,8), Vector2(34,8) + Vector2(0, -10), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween_anim.interpolate_property(gold_coin_anim, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween_anim.start()

func _handle_heroes_died():
	emit_signal("battle_finished", false)
	$timer_battle_tick.stop()

func _handle_enemies_died():
	$button_give_up_adventure.hide()
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.get_parent().remove_child(enemy)
		enemy.queue_free()
	_set_available_gold(available_gold + next_gold_reward)
	$enemy_health_bar.hide()
	$timer_battle_tick.stop()
	emit_signal("battle_finished", true)

func _show_battle_state():
	$hero_health_bar.show()
	$button_start_adventure.hide()
	$button_shop.hide()
	$button_ability_hurry.show()
	$dice_tray.hide()
	_update_bleed()
	var heroes_dices = get_tree().get_nodes_in_group("heroes_dice")
	for heroes_dice in heroes_dices:
		if !heroes_dice.is_in_play:
			heroes_dice.hide()

func _hide_battle_state():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.get_parent().remove_child(enemy)
		enemy.queue_free()
	$hero_health_bar.hide()
	$enemy_health_bar.hide()
	$button_ability_hurry.hide()
	$button_shop.show()
	$button_give_up_adventure.hide()
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
	var spawners = get_tree().get_nodes_in_group("hero_spawners")
	for spawner in spawners:
		if !spawner.has_hero():
			spawner.spawn_hero(characterObj)
			return

func _on_character_shop_retracted_hero(characterObj):
	characterObj.is_in_play = false
	var spawners = get_tree().get_nodes_in_group("hero_spawners")
	for spawner in spawners:
		if spawner.has_hero() && spawner.get_hero().hero_type == characterObj.hero_type:
			spawner.remove_hero()
			return

func _on_character_shop_sent_hero(characterObj):
	characterObj.is_in_play = true
	var spawners = get_tree().get_nodes_in_group("hero_spawners")
	for spawner in spawners:
		if !spawner.has_hero():
			spawner.spawn_hero(characterObj)
			return

func _on_character_shop_purchased_health(cost):
	_set_available_gold(available_gold - cost)
	_set_hero_life_max(hero_life_max + 1)
	_set_hero_life_current(hero_life_max)

func _get_next_dice_spawn_location():
	return Vector2(64, 24)

func _on_board_new_zone_entered(battle):
	$button_give_up_adventure.show()
	var index = 0
	var spawners = get_tree().get_nodes_in_group("enemy_spawners")
	for spawner in spawners:
		if (index < battle.enemies.size()):
			spawner.spawn_enemy(battle.enemies[index])
			index += 1
	_set_enemy_life_max(battle.enemy_group_health)
	_set_enemy_life_current(battle.enemy_group_health)
	next_gold_reward = battle.gold_income
	current_battle_bleed_stacks = 0
	current_battle_bleed_damage_sum = 0
	_update_bleed()
	$enemy_health_bar.show()
	$timer_battle_tick.start()

func _update_bleed():
	$enemy_health_bar/bleed_stack_counter.text = str(current_battle_bleed_stacks)
	if current_battle_bleed_stacks > 0:
		$enemy_health_bar/bleed_stack_counter.show()
		$enemy_health_bar/bleed_icon.show()
	else:
		$enemy_health_bar/bleed_stack_counter.hide()
		$enemy_health_bar/bleed_icon.hide()

func _on_board_final_zone_completed():
	_hide_battle_state()
	$timer_battle_tick.stop()
	is_adventure_started = false
	$victory_dialog.popup_centered_ratio(0.5)
	global_audio.play_victory_sound()

func _on_board_entered_start_zone():
	$button_start_adventure.show()
	_hide_battle_state()
	is_adventure_started = false
	$button_ability_hurry.pressed = false
	_on_button_ability_hurry_pressed() # reset timer because we disable hurry button -- does not fire automatically

func _on_button_give_up_adventure_pressed():
	global_audio.play_ui()
	$button_give_up_adventure.hide()
	_set_hero_life_current(0)
	_handle_heroes_died()

