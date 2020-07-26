extends Panel
class_name ScenarioSelector

var _scenario_data = []

var _selected_scenario
var _selected_faction

func _ready():
	var dir = Directory.new()
	var path = "res://Scenarios"
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var in_dir_name = dir.get_next()
		if in_dir_name == "":
			break
		elif not in_dir_name.begins_with(".") and dir.current_is_dir():
			var scen_path = "res://Scenarios/" + in_dir_name + "/Scenario.json"
			var file = File.new()
			file.open(scen_path, File.READ)
			var obj = parse_json(file.get_as_text())
			obj['__FileName'] = in_dir_name
			if obj != null:
				_scenario_data.append(obj)
			file.close()
			
	for scen in _scenario_data:
		var hcontainer = HBoxContainer.new()
		
		var radioButton = CheckBox.new()
		hcontainer.add_child(radioButton)
		radioButton.connect("pressed", self, "_on_scenario_clicked", [radioButton, scen])
		radioButton.add_to_group("RadioButton_Scenario")
		
		var label = Label.new()
		label.text = scen['Name']
		hcontainer.add_child(label)
		
		$ScenarioContainer/Scenarios.add_child(hcontainer)
		
		
func _on_scenario_clicked(node, scen):
	Util.delete_all_children($FactionContainer/Factions)
	if node.is_pressed():
		for n in get_tree().get_nodes_in_group("RadioButton_Scenario"):
			n.set_pressed(false)
		node.set_pressed(true)
		
		for faction in scen['Factions']:
			var hcontainer = HBoxContainer.new()
			
			var radioButton = CheckBox.new()
			hcontainer.add_child(radioButton)
			radioButton.connect("pressed", self, "_on_faction_clicked", [radioButton, scen, faction])
			radioButton.add_to_group("RadioButton_Faction")
			
			var label = Label.new()
			label.text = faction['Name']
			hcontainer.add_child(label)
			
			$FactionContainer/Factions.add_child(hcontainer)
			
func _on_faction_clicked(node, scen, faction):
	if node.is_pressed():
		for n in get_tree().get_nodes_in_group("RadioButton_Faction"):
			n.set_pressed(false)
		node.set_pressed(true)
		
		_selected_scenario = scen['__FileName']
		_selected_faction = faction['_Id']
		$Confirm.disabled = false
	else:
		$Confirm.disabled = true


func _on_Cancel_pressed():
	hide()


func _on_Confirm_pressed():
	SharedData.loading_file_path = "res://Scenarios/" + _selected_scenario
	SharedData.starting_faction_id = _selected_faction
	get_tree().change_scene("res://Main.tscn")
