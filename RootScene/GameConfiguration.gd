extends Panel
class_name GameConfiguration

func _on_Confirm_pressed():
	var config = ScenarioConfig.new()
	config.ai_fund_rate = float($Tabs/CONFIG_DIFFICULTY/G/AIFundRate.text)
	config.ai_food_rate = float($Tabs/CONFIG_DIFFICULTY/G/AIFoodRate.text)
	config.ai_troop_recruit_rate = float($Tabs/CONFIG_DIFFICULTY/G/AIRecruitRate.text)
	config.ai_troop_training_rate = float($Tabs/CONFIG_DIFFICULTY/G/AITrainingRate.text)
	config.ai_troop_offence_rate = float($Tabs/CONFIG_DIFFICULTY/G/AIOffenceRate.text)
	config.ai_troop_defence_rate = float($Tabs/CONFIG_DIFFICULTY/G/AIDefenceRate.text)
	
	config.person_natural_death = $Tabs/BASIC/G/PersonNaturalDeath.pressed
	
	SharedData.starting_scenario_config = config
	
	GameConfig.load_game_config()
	get_tree().change_scene("res://Main.tscn")


func _on_Cancel_pressed():
	hide()


func _on_PersonNaturalDeath_visibility_changed():
	if visible:
		var loading_file_path = SharedData.loading_file_path
		var scenario_config = ScenarioConfig.new()
		
		var file = File.new()
		if file.open(loading_file_path + "/ScenarioConfig.json", File.READ) == OK:
			var obj = parse_json(file.get_as_text())
			scenario_config.ai_fund_rate = float(Util.dict_try_get(obj, 'AIFundRate', 1.0))
			scenario_config.ai_food_rate = float(Util.dict_try_get(obj, 'AIFoodRate', 1.0))
			scenario_config.ai_troop_recruit_rate = float(Util.dict_try_get(obj, 'AITroopRecruitRate', 1.0))
			scenario_config.ai_troop_training_rate = float(Util.dict_try_get(obj, 'AITroopTrainingRate', 1.0))
			scenario_config.ai_troop_offence_rate = float(Util.dict_try_get(obj, 'AITroopOffenceRate', 1.0))
			scenario_config.ai_troop_defence_rate = float(Util.dict_try_get(obj, 'AITroopDefenceRate', 1.0))
			scenario_config.person_natural_death = Util.dict_try_get(obj, "PersonNaturalDeath", true)
			file.close()
			
		$Tabs/CONFIG_DIFFICULTY/G/AIFundRate.text = str(scenario_config.ai_fund_rate)
		$Tabs/CONFIG_DIFFICULTY/G/AIFoodRate.text = str(scenario_config.ai_food_rate)
		$Tabs/CONFIG_DIFFICULTY/G/AIRecruitRate.text = str(scenario_config.ai_troop_recruit_rate)
		$Tabs/CONFIG_DIFFICULTY/G/AITrainingRate.text = str(scenario_config.ai_troop_training_rate)
		$Tabs/CONFIG_DIFFICULTY/G/AIOffenceRate.text = str(scenario_config.ai_troop_offence_rate)
		$Tabs/CONFIG_DIFFICULTY/G/AIDefenceRate.text = str(scenario_config.ai_troop_defence_rate)
		
		$Tabs/BASIC/G/PersonNaturalDeath.pressed = scenario_config.person_natural_death
	
