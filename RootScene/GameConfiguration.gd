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
	SharedData.starting_scenario_config = config
	
	get_tree().change_scene("res://Main.tscn")


func _on_Cancel_pressed():
	hide()
