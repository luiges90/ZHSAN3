extends Node
class_name ResourcePack

var fund
var food
var troop
var troop_morale
var day_left

func dict_for_json():
	return {
		"Fund": fund,
		"Food": food,
		"Troop": troop,
		"TroopMorale": troop_morale,
		"DayLeft": day_left
	}
	
func set_from_json_dict(dict):
	fund = dict["Fund"]
	food = dict["Food"]
	troop = dict["Troop"]
	troop_morale = dict["TroopMorale"]
	day_left = dict["DayLeft"]
