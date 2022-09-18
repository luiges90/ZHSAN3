extends Panel
class_name GameConfiguration

func _on_Confirm_pressed():
	var config = ScenarioConfig.new()
	config.ai_fund_rate = float($TabBar/CONFIG_DIFFICULTY/G/AIFundRate.text)
	config.ai_food_rate = float($TabBar/CONFIG_DIFFICULTY/G/AIFoodRate.text)
	config.ai_troop_recruit_rate = float($TabBar/CONFIG_DIFFICULTY/G/AIRecruitRate.text)
	config.ai_troop_training_rate = float($TabBar/CONFIG_DIFFICULTY/G/AITrainingRate.text)
	config.ai_troop_offence_rate = float($TabBar/CONFIG_DIFFICULTY/G/AIOffenceRate.text)
	config.ai_troop_defence_rate = float($TabBar/CONFIG_DIFFICULTY/G/AIDefenceRate.text)
	
	config.person_natural_death = $TabBar/BASIC/G/PersonNaturalDeath.pressed
	
	SharedData.starting_scenario_config = config
	
	GameConfig.load_game_config()
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_Cancel_pressed():
	hide()


func _on_PersonNaturalDeath_visibility_changed():
	if visible:
		var loading_file_path = SharedData.loading_file_path
		var scenario_config = ScenarioConfig.new()
		
		var file = File.new()
		if file.open(loading_file_path + "/ScenarioConfig.json", File.READ) == OK:
			var test_json_conv = JSON.new()
			test_json_conv.parse(file.get_as_text())
			var obj = test_json_conv.get_data()
			scenario_config.ai_fund_rate = float(Util.dict_try_get(obj, 'AIFundRate', 1.0))
			scenario_config.ai_food_rate = float(Util.dict_try_get(obj, 'AIFoodRate', 1.0))
			scenario_config.ai_troop_recruit_rate = float(Util.dict_try_get(obj, 'AITroopRecruitRate', 1.0))
			scenario_config.ai_troop_training_rate = float(Util.dict_try_get(obj, 'AITroopTrainingRate', 1.0))
			scenario_config.ai_troop_offence_rate = float(Util.dict_try_get(obj, 'AITroopOffenceRate', 1.0))
			scenario_config.ai_troop_defence_rate = float(Util.dict_try_get(obj, 'AITroopDefenceRate', 1.0))
			scenario_config.person_natural_death = Util.dict_try_get(obj, "PersonNaturalDeath", true)
			file.close()
			
		$TabBar/CONFIG_DIFFICULTY/G/AIFundRate.text = str(scenario_config.ai_fund_rate)
		$TabBar/CONFIG_DIFFICULTY/G/AIFoodRate.text = str(scenario_config.ai_food_rate)
		$TabBar/CONFIG_DIFFICULTY/G/AIRecruitRate.text = str(scenario_config.ai_troop_recruit_rate)
		$TabBar/CONFIG_DIFFICULTY/G/AITrainingRate.text = str(scenario_config.ai_troop_training_rate)
		$TabBar/CONFIG_DIFFICULTY/G/AIOffenceRate.text = str(scenario_config.ai_troop_offence_rate)
		$TabBar/CONFIG_DIFFICULTY/G/AIDefenceRate.text = str(scenario_config.ai_troop_defence_rate)
		
		$TabBar/BASIC/G/PersonNaturalDeath.button_pressed = scenario_config.person_natural_death
	
