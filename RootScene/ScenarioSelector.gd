extends Panel
class_name ScenarioSelector

var _scenario_data = []

var _selected_scenario
var _selected_faction

var _all_custom_persons = {}
var _all_architectures = {}
var _all_factions = {}
var _selected_custom_persons = []

signal confirmed_scenario

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
			if file.open(scen_path, File.READ) == OK:
				var obj = parse_json(file.get_as_text())
				if obj != null:
					obj['__FileName'] = in_dir_name
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
		
	var file = File.new()
	if file.open('user://custom_persons.json', File.READ) == OK:
		var obj = parse_json(file.get_as_text())
		for item in obj:
			var instance = Person.new()
			instance.load_data(item, {})
			_all_custom_persons[instance.id] = instance
		file.close()
		
		
func _on_scenario_clicked(node, scen):
	Util.delete_all_children($FactionContainer/Factions)
	if node.is_pressed():
		for n in get_tree().get_nodes_in_group("RadioButton_Scenario"):
			n.set_pressed(false)
		node.set_pressed(true)
		
		_selected_scenario = scen['__FileName']
		$HL/CustomOfficers.disabled = _selected_scenario == null
		
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
			
			_all_factions[faction['_Id']] = faction
		
		for a in scen['Architectures']:
			_all_architectures[a['_Id']] = a
		
		
func _on_faction_clicked(node, scen, faction):
	if node.is_pressed():
		for n in get_tree().get_nodes_in_group("RadioButton_Faction"):
			n.set_pressed(false)
		node.set_pressed(true)
		
		_selected_faction = faction['_Id']
		
		$Confirm.disabled = _selected_faction == null


func _on_Cancel_pressed():
	hide()


func _on_Confirm_pressed():
	SharedData.loading_file_path = "res://Scenarios/" + _selected_scenario
	SharedData.starting_faction_id = _selected_faction
	call_deferred("emit_signal", "confirmed_scenario")
	

func _on_CustomOfficers_pressed():
	$PersonList.select_custom_officers(_all_custom_persons.values(), _selected_custom_persons)


func _on_PersonList_person_selected(current_action, current_architecture, selected):
	_selected_custom_persons = []
	for pid in selected:
		_selected_custom_persons.append(_all_custom_persons[pid])
	$HL/NewFactions.disabled = selected.size() <= 0
		

func _on_NewFactions_pressed():
	var avail_arch = []
	for a in _all_architectures:
		var taken = false
		for f in _all_factions:
			if _all_factions[f]['Architectures'].has(a):
				taken = true
				break
		if not taken:
			avail_arch.append(_all_architectures[a])
	$ArchitectureList.select_architecture_for_new_faction(avail_arch)
