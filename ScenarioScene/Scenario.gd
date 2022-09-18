extends Node
class_name Scenario

@onready var tile_size: int = $Map.tile_size if has_node("Map") else 0
@onready var map_size: Vector2 = $Map.map_size if has_node("Map") else Vector2(0,0)

const GROUP_GAME_INSTANCES = "game_instances"

var ai: AI

var current_faction

var turn_passed = 0

var terrain_details = Dictionary() :
	get:
		return terrain_details # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var movement_kinds = Dictionary() :
	get:
		return movement_kinds # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var architecture_kinds = Dictionary() :
	get:
		return architecture_kinds # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var architecture_specialties = Dictionary() :
	get:
		return architecture_specialties # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var military_kinds = Dictionary() :
	get:
		return military_kinds # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var skills = Dictionary() :
	get:
		return skills # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var stunts = Dictionary() :
	get:
		return stunts # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var ai_paths = Dictionary() :
	get:
		return ai_paths # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var factions = Dictionary() :
	get:
		return factions # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var sections = Dictionary() :
	get:
		return sections # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var architectures = Dictionary() :
	get:
		return architectures # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var persons = Dictionary() :
	get:
		return persons # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var troops = Dictionary() :
	get:
		return troops # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var attached_armies = Dictionary() :
	get:
		return attached_armies # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var biographies = Dictionary() :
	get:
		return biographies # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var current_scenario_name = null

var _architecture_clicked
var _troop_clicked
var _clicked_at: Vector2
var _right_clicked = false

var scenario_config: ScenarioConfig :
	get:
		return scenario_config # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var _loading_scenario = false
var _starting_camera_move_to
var _starting_camera_zoom_to

var __right_click_on_blank_detected = false

signal current_faction_set
signal scenario_loaded

signal architecture_clicked
signal architecture_survey_updated
signal troop_clicked
signal troop_survey_updated
signal architecture_and_troop_clicked
signal faction_survey_updated
signal person_move_clicked

signal empty_space_right_clicked

signal all_faction_finished

signal scenario_camera_moved
signal mouse_moved_to_map_position

signal scenario_architecture_faction_changed

signal scenario_troop_created
signal scenario_troop_removed
signal scenario_troop_position_changed

signal create_troop_from_attached_army_select_position

func forbidden(x):
	assert(false)

# Called when the node enters the scene tree for the first time.
func _ready(headless = false):
	var ai_script = preload("AI/AI.gd")
	ai = ai_script.new()
	
	var camera
	if not headless:
		camera = $MainCamera as MainCamera
		camera.scenario = self
		($DateRunner as DateRunner).scenario = self
	
	var new_game = false
	if SharedData.loading_file_path == null:
		SharedData.loading_file_path = "res://Scenarios/194QXGJ-qh"
		current_scenario_name = "194QXGJ-qh"
		new_game = true
	else: 
		var pos = SharedData.loading_file_path.find('Scenarios')
		if pos >= 0:
			current_scenario_name = SharedData.loading_file_path.substr(pos + 10)
			new_game = true
	_load_data(SharedData.loading_file_path, new_game, headless)
	
	if not headless:
		if _starting_camera_move_to != null:
			camera.position = _starting_camera_move_to
			camera.zoom = _starting_camera_zoom_to
			camera.call_deferred("emit_signal", "camera_moved", camera.get_viewing_rect(), camera.zoom)
			call_deferred("emit_signal", "scenario_camera_moved", camera.get_viewing_rect(), camera.zoom, self)
		else:
			var player_factions = get_player_factions()
			if player_factions.size() > 0:
				var fid = player_factions[0]
				camera.position = factions[fid].get_architectures()[0].position
				camera.call_deferred("emit_signal", "camera_moved", camera.get_viewing_rect(), camera.zoom)
				call_deferred("emit_signal", "scenario_camera_moved", camera.get_viewing_rect(), camera.zoom, self)
		
		$DateRunner.connect("day_passed",Callable(self,"_on_day_passed"))
		$DateRunner.connect("month_passed",Callable(self,"_on_month_passed"))
	
	
	
func get_camera_viewing_rect() -> Rect2:
	var camera = $MainCamera as MainCamera
	return camera.get_viewing_rect()
	
func get_camera_zoom() -> Vector2:
	var camera = $MainCamera as MainCamera
	return camera.zoom

########################################
#             Save / Load              #
########################################
	
func _on_file_slot_clicked(mode, path: String):
	if mode == SaveLoadMenu.MODE.SAVE:
		_save_data(path)
	else:
		_load_data(path, false, false)
	
func _save_data(path):
	var dir = Directory.new()
	dir.make_dir_recursive(path)
	
	var date = $DateRunner as DateRunner
	
	var file = File.new()
	file.open(path + "/Scenario.json", File.WRITE)
	file.store_line(JSON.new().stringify(
		{
			"CurrentFactionId": current_faction.id,
			"Scenario": current_scenario_name,
			"GameData": {
				"Year": date.year,
				"Month": date.month,
				"Day": date.day,
				"TurnPassed": turn_passed
			},
			"Camera3D": {
				"Position": Util.save_position($MainCamera.position),
				"Zoom": Util.save_position($MainCamera.zoom)
			}
		}
	))
	file.close()
	
	file.open(path + "/Skills.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(skills)))
	file.close()

	file.open(path + "/Stunts.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(stunts)))
	file.close()
	
	file.open(path + "/TerrainDetails.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(terrain_details)))
	file.close()
	
	file.open(path + "/MovementKinds.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(movement_kinds)))
	file.close()
	
	file.open(path + "/MilitaryKinds.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(military_kinds)))
	file.close()

	file.open(path + "/ArchitectureSpecialties.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(architecture_specialties)))
	file.close()
	
	file.open(path + "/ArchitectureKinds.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(architecture_kinds)))
	file.close()
	
	file.open(path + "/Factions.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(factions)))
	file.close()
	
	file.open(path + "/Sections.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(sections)))
	file.close()
	
	file.open(path + "/Architectures.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(architectures)))
	file.close()
	
	file.open(path + "/Troops.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(troops)))
	file.close()

	file.open(path + "/AttachedArmies.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(attached_armies)))
	file.close()
	
	file.open(path + "/Persons.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(persons)))
	file.close()
	
	file.open(path + "/Biographies.json", File.WRITE)
	file.store_line(JSON.new().stringify(__save_items(biographies)))
	file.close()
	
	file.open(path + "/ScenarioConfig.json", File.WRITE)
	file.store_line(JSON.new().stringify({
		"AIFundRate": scenario_config.ai_fund_rate,
		"AIFoodRate": scenario_config.ai_food_rate,
		"AITroopRecruitRate": scenario_config.ai_troop_recruit_rate,
		"AITroopTrainingRate": scenario_config.ai_troop_training_rate,
		"AITroopOffenceRate": scenario_config.ai_troop_offence_rate,
		"AITroopDefenceRate": scenario_config.ai_troop_defence_rate,
		"OfficerDeath": scenario_config.person_natural_death
	}))
	file.close()

	
func __save_items(d: Dictionary):
	var arr = []
	for item in d.values():
		if item is Troop and item._destroyed:
			continue
		if item is Faction and item._destroyed:
			continue
		arr.push_back(item.save_data())
	return arr

func _load_data(path, new_game, headless):
	_loading_scenario = true
	if not headless:
		for n in get_tree().get_nodes_in_group(GROUP_GAME_INSTANCES):
			remove_child(n)
			n.queue_free()
	
	var file = File.new()
	var obj
	var current_faction_id
	
	if not headless:
		file.open(path + "/Scenario.json", File.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		
		var date = $DateRunner as DateRunner
		date.year = obj["GameData"]["Year"]
		date.month = obj["GameData"]["Month"]
		date.day = obj["GameData"]["Day"]
		current_faction_id = obj["CurrentFactionId"]
		var current_name = obj.get("Scenario")
		if current_name != null:
			current_scenario_name = current_name
		turn_passed = obj["GameData"]["TurnPassed"]
		if obj.has("Camera3D"):
			_starting_camera_move_to = Util.load_position(obj["Camera3D"]["Position"])
			_starting_camera_zoom_to = Util.load_position(obj["Camera3D"]["Zoom"])
		file.close()
	
	if file.open(path + "/ScenarioConfig.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		scenario_config = ScenarioConfig.new()
		scenario_config.ai_fund_rate = float(Util.dict_try_get(obj, 'AIFundRate', 1.0))
		scenario_config.ai_food_rate = float(Util.dict_try_get(obj, 'AIFoodRate', 1.0))
		scenario_config.ai_troop_recruit_rate = float(Util.dict_try_get(obj, 'AITroopRecruitRate', 1.0))
		scenario_config.ai_troop_training_rate = float(Util.dict_try_get(obj, 'AITroopTrainingRate', 1.0))
		scenario_config.ai_troop_offence_rate = float(Util.dict_try_get(obj, 'AITroopOffenceRate', 1.0))
		scenario_config.ai_troop_defence_rate = float(Util.dict_try_get(obj, 'AITroopDefenceRate', 1.0))
		scenario_config.person_natural_death = Util.dict_try_get(obj, "PersonNaturalDeath", true)
		file.close()
	
	if file.open(path + "/Skills.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = Skill.new()
			__load_item(instance, item, skills, {})
		file.close()

	if file.open(path + "/Stunts.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = Stunt.new()
			__load_item(instance, item, stunts, {})
		file.close()
	
	if file.open(path + "/TerrainDetails.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = TerrainDetail.new()
			__load_item(instance, item, terrain_details, {})
		file.close()
	
	if file.open(path + "/MovementKinds.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = MovementKind.new()
			__load_item(instance, item, movement_kinds, {})
		file.close()
	
	for kind in movement_kinds:
		if movement_kinds[kind].naval:
			continue
		var err = file.open(path + "/paths/" + str(kind) + '.json', File.READ)
		if err != OK:
			err = file.open("res://Scenarios/" + current_scenario_name + "/paths/" + str(kind) + '.json', File.READ)
		if err == OK:
			var test_json_conv = JSON.new()
			test_json_conv.parse(file.get_as_text())
			obj = test_json_conv.get_data()
			var ai_path = AIPaths.new()
			ai_path.load_data(obj)
			ai_paths[kind] = ai_path
			file.close()
			
	if file.open(path + "/MilitaryKinds.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = MilitaryKind.new()
			__load_item(instance, item, military_kinds, {})
		file.close()
		SharedData._load_troop_sprite_frames(military_kinds.values())
	
	if file.open(path + "/ArchitectureKinds.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = ArchitectureKind.new()
			__load_item(instance, item, architecture_kinds, {})
		file.close()

	if file.open(path + "/ArchitectureSpecialties.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = ArchitectureSpecialty.new()
			__load_item(instance, item, architecture_specialties, {})
		file.close()
	
	if file.open(path + "/Biographies.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = Biography.new()
			__load_item(instance, item, biographies, {})
		file.close()

	if file.open(path + "/AttachedArmies.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = AttachedArmy.new()
			__load_item(instance, item, attached_armies, {'military_kinds': military_kinds})
		file.close()

	var person_json = {}
	if file.open(path + "/Persons.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = Person.new()
			
			instance.connect("person_available",Callable(self,"_on_person_available"))
			
			var game_record_creator = get_node_or_null("GameRecordCreator")
			if game_record_creator != null:
				instance.connect('person_died',Callable(game_record_creator,'person_died'))
				instance.connect("convince_success",Callable(game_record_creator,"person_convince_success"))
				instance.connect("convince_failure",Callable(game_record_creator,"person_convince_failure"))
				instance.connect("move_complete",Callable(game_record_creator,"person_move_complete"))
				
			__load_item(instance, item, persons, {"skills": skills, "stunts": stunts, "attached_armies": attached_armies})
			person_json[instance.id] = item
		file.close()
	
	if new_game:
		if file.open('user://custom_persons.json', File.READ) == OK:
			var test_json_conv = JSON.new()
			test_json_conv.parse(file.get_as_text())
			obj = test_json_conv.get_data()
			for item in obj:
				var instance = Person.new()
				
				instance.connect("person_available",Callable(self,"_on_person_available"))
				
				var game_record_creator = get_node_or_null("GameRecordCreator")
				if game_record_creator != null:
					instance.connect('person_died',Callable(game_record_creator,'person_died'))
					instance.connect("convince_success",Callable(game_record_creator,"person_convince_success"))
					instance.connect("convince_failure",Callable(game_record_creator,"person_convince_failure"))
					instance.connect("move_complete",Callable(game_record_creator,"person_move_complete"))
					
				__load_item(instance, item, persons, {"skills": skills, "stunts": stunts})
				person_json[instance.id] = item
			file.close()
			
		for pid in persons:
			var father_id = int(person_json[pid]["FatherId"])
			if father_id >= 0:
				persons[pid].set_father(persons[father_id])
			var mother_id = int(person_json[pid]["MotherId"])
			if mother_id >= 0:
				persons[pid].set_mother(persons[mother_id])
			var spouse_ids = person_json[pid]["SpouseIds"]
			for s in spouse_ids:
				persons[pid].add_spouse(persons[int(s)])
			var brother_ids = person_json[pid]["BrotherIds"]
			for b in brother_ids:
				persons[pid].add_brother(persons[int(b)])
			var task_target_id = int(person_json[pid]["TaskTarget"])
			if task_target_id >= 0:
				persons[pid].set_task_target(persons[task_target_id])
	
	if file.open(path + "/Architectures.json", File.READ) == OK:
		var architecture_scene = preload("Architecture/Architecture.tscn")
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = architecture_scene.instantiate()
			instance.connect("architecture_clicked",Callable(self,"_on_architecture_clicked"))
			instance.connect("architecture_survey_updated",Callable(self,"_on_architecture_survey_updated"))
			instance.connect("faction_changed",Callable(self,"_on_architecture_faction_changed"))
			__load_item(instance, item, architectures, {"persons": persons, "architecture_specialties": architecture_specialties})
			instance.setup_after_load()
		file.close()
		for item in architectures:
			architectures[item].set_adjacency(architectures, ai_paths)
		
	if file.open(path + "/Troops.json", File.READ) == OK:
		var troop_scene = preload("Military/Troop.tscn")
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		var troop_json = {}
		for item in obj:
			var instance = troop_scene.instantiate()
			__load_item(instance, item, troops, {"persons": persons, "stunts": stunts})
			troop_json[instance.id] = item
		file.close()
		for tid in troops:
			var order_type = troop_json[tid]["_CurrentOrderType"]
			if order_type != null:
				var order_target_raw = troop_json[tid]["_CurrentOrderTarget"]
				var order_target_type = troop_json[tid]["_CurrentOrderTargetType"]
				var order_target_stunt = troop_json[tid]["_CurrentOrderStunt"]
				var order_target_stunt_level = troop_json[tid]["_CurrentOrderStuntLevel"]
				
				var target 
				if order_target_type == "Position":
					target = Util.load_position(order_target_raw)
				elif order_target_type == "Architecture":
					target = architectures[int(order_target_raw)]
				elif order_target_type == "Troop":
					target = troops[int(order_target_raw)]
				
				if order_type == Troop.OrderType.MOVE:
					troops[tid].set_move_order(target)
				elif order_type == Troop.OrderType.ATTACK:
					troops[tid].set_attack_order(target, null)
				elif order_type == Troop.OrderType.FOLLOW:
					troops[tid].set_follow_order(target)
				elif order_type == Troop.OrderType.ENTER:
					troops[tid].set_enter_order(target.map_position)
				elif order_type == Troop.OrderType.ACTIVATE_STUNT:
					var stunt
					if order_target_stunt >= 0:
						stunt = stunts[int(order_target_stunt)]
					else:
						assert(false) #,"Stunt not found: " + str(order_target_stunt))
					troops[tid].set_activate_stunt_order(stunt, order_target_stunt_level, target)
				else:
					assert(false) #,"Unexpected order type " + str(order_type))

			for s in troop_json[tid]["_ActiveStunts"]:
				var stunt
				if s["stunt"] >= 0:
					stunt = stunts[int(s["stunt"])]
				else:
					assert(false) #,"Stunt not found: " + str(s["stunt"]))
				troops[tid].active_stunt_effects.append({
					"stunt": stunt,
					"level": s["level"],
					"days": s["days"]
				})
				troops[tid].call_deferred("_update_stunt_animations")
		
	var section_ids = []
	if file.open(path + "/Sections.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = Section.new()
			__load_item(instance, item, sections, {"architectures": architectures, "troops": troops})
			section_ids.append(instance.id)
	
	var faction_ids = []
	if file.open(path + "/Factions.json", File.READ) == OK:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		obj = test_json_conv.get_data()
		for item in obj:
			var instance = Faction.new()
			instance.connect("destroyed",Callable($GameRecordCreator,"_on_faction_destroyed"))
			__load_item(instance, item, factions, {"sections": sections})
			instance._set_leader(persons[int(item["Leader"])])
			if item["Advisor"] >= 0:
				instance._set_advisor(persons[int(item["Advisor"])])
			instance.set_capital(architectures[int(item["Capital"])])
			faction_ids.append(instance.id)
		file.close()
	
	for t in troops:
		__connect_signals_for_creating_troop(troops[t])

	if not headless and SharedData.custom_factions != null:
		var section_id = section_ids.max() + 1
		var faction_id = faction_ids.max() + 1
		for f in SharedData.custom_factions:
			var f_leader = f["leader"]
			var f_architecture_id = []
			for arch in f["architectures"]:
				f_architecture_id.append(arch["_Id"])
			var capital = architectures[int(f_architecture_id[0])]

			for p in f["persons"]:
				if persons[p.id].get_age() >= 15:
					capital.add_person(persons[p.id])
					persons[p.id].join_architecture(capital)
				else:
					persons[p.id].set_active()
			
			var section = Section.new()
			__load_item(section, {
				"_Id": section_id, 
				"Name": capital.get_name() + tr('SECTION'), 
				"ArchitectureList": f_architecture_id, 
				"TroopList": []
			}, sections, {"architectures": architectures, "troops": troops})

			var faction = Faction.new()
			faction.connect("destroyed",Callable($GameRecordCreator,"_on_faction_destroyed"))
			__load_item(faction, 
				{
					"Advisor": -1,
					"Capital": capital.id,
					"Color": [randf(), randf(), randf()],
					"Leader": f_leader.id,
					"Name": f_leader.get_name(),
					"PlayerControlled": SharedData.starting_faction_id == f_leader.id,
					"SectionList": [section_id],
					"_Id": f_leader.id
				}, factions, {"sections": sections})
			faction._set_leader(persons[f_leader.id])
			faction.set_capital(capital)

			section_id += 1
			faction_id += 1
	
	if not headless:
		__handle_game_start(current_faction_id)
		call_deferred("emit_signal", "scenario_loaded", self)

	_loading_scenario = false

	
func __load_item(instance, item, add_to_list, objects):
	if instance.has_method("set_scenario"):
		instance.set_scenario(self)
	else:
		instance.scenario = self
		
	instance.load_data(item, objects)
	add_to_list[int(instance.id)] = instance
	if instance is Architecture or instance is Troop:
		instance.add_to_group(GROUP_GAME_INSTANCES)
		add_child(instance)
	
func __handle_game_start(current_faction_id):
	if SharedData.starting_faction_id != null:
		current_faction = factions[int(SharedData.starting_faction_id)]
		current_faction.player_controlled = true
	else:
		current_faction = factions[int(current_faction_id)]
		
	if SharedData.starting_scenario_config != null:
		scenario_config = SharedData.starting_scenario_config
		
func __connect_signals_for_creating_troop(troop):
	troop.connect("troop_clicked",Callable(self,"_on_troop_clicked"))
	troop.connect("troop_survey_updated",Callable(self,"_on_troop_survey_updated"))
	troop.connect("occupy_architecture",Callable($GameRecordCreator,"_on_troop_occupy_architecture"))
	troop.connect("position_changed",Callable(self,"_on_troop_position_changed"))
	troop.connect("removed",Callable(self,"_on_troop_removed"))
	troop.connect("destroyed",Callable($GameRecordCreator,"_on_troop_destroyed"))
	troop.connect("person_captured",Callable($GameRecordCreator,"_on_troop_person_captured"))
	troop.connect("person_released",Callable($GameRecordCreator,"_on_troop_person_released"))
	troop.connect("performed_attack",Callable($GameRecordCreator,"_on_troop_performed_attack"))
	troop.connect("received_attack",Callable($GameRecordCreator,"_on_troop_received_attack"))
	troop.connect("target_architecture_destroyed",Callable($GameRecordCreator,"_on_troop_target_architecture_destroyed"))
	troop.connect("target_troop_destroyed",Callable($GameRecordCreator,"_on_troop_target_troop_destroyed"))	
	troop.connect("start_stunt",Callable($GameRecordCreator,"_on_troop_start_stunt"))
	
	
	_on_troop_created(troop, troop.map_position)
	

########################################
#           UI signal handling         #
########################################
	
func _on_architecture_clicked(arch, mx, my, right_clicked):
	_architecture_clicked = arch
	_clicked_at = Vector2(mx, my)
	_right_clicked = right_clicked
	
func _on_architecture_survey_updated(arch):
	call_deferred("emit_signal", "architecture_survey_updated", arch)
	call_deferred("emit_signal", "faction_survey_updated")
	
func _on_architecture_faction_changed(arch):
	call_deferred("emit_signal", "scenario_architecture_faction_changed", arch, self)
	call_deferred("emit_signal", "faction_survey_updated")
	
func _on_troop_clicked(troop, mx, my, right_clicked):
	_troop_clicked = troop
	_clicked_at = Vector2(mx, my)
	_right_clicked = right_clicked
	
func _on_troop_survey_updated(troop):
	call_deferred("emit_signal", "troop_survey_updated", troop)
	
func on_architecture_remove_advisor(current_architecture):
	$GameRecordCreator.remove_advisor(current_architecture.get_belonged_faction())
	current_architecture.get_belonged_faction()._set_advisor(null)
	
func on_architecture_auto_convince(current_architecture):
	current_architecture.toggle_auto_convince()
	
func _on_person_selected(task, current_architecture, selected_person_ids, other = {}):
	var selected_persons = []
	for id in selected_person_ids:
		selected_persons.append(persons[id])
	match task:
		PersonList.Action.AGRICULTURE: current_architecture.set_person_task(Person.Task.AGRICULTURE, selected_persons)
		PersonList.Action.COMMERCE: current_architecture.set_person_task(Person.Task.COMMERCE, selected_persons)
		PersonList.Action.MORALE: current_architecture.set_person_task(Person.Task.MORALE, selected_persons)
		PersonList.Action.ENDURANCE: current_architecture.set_person_task(Person.Task.ENDURANCE, selected_persons)
		PersonList.Action.RECRUIT_TROOP: current_architecture.set_person_task(Person.Task.RECRUIT_TROOP, selected_persons)
		PersonList.Action.TRAIN_TROOP: current_architecture.set_person_task(Person.Task.TRAIN_TROOP, selected_persons)
		PersonList.Action.CALL:
			for p in selected_persons:
				p.move_to_architecture(current_architecture)
			call_deferred("emit_signal", "person_move_clicked", selected_persons, current_architecture)
		PersonList.Action.SELECT_ADVISOR:
			current_architecture.get_belonged_faction()._set_advisor(selected_persons[0])
			$GameRecordCreator.assign_advisor(selected_persons[0])
		PersonList.Action.CONVINCE_PERSON:
			selected_persons[0].go_for_convince(other['target'])
			

func _on_architecture_selected(current_action, current_architecture, selected_arch_ids, other = {}):
	if current_action == ArchitectureList.Action.MOVE_TO:
		var selected_person_ids = other['selected_person_ids']
		var a = architectures[selected_arch_ids[0]]
		for id in selected_person_ids:
			var p = persons[id]
			p.move_to_architecture(a)
		
func _on_military_kind_selected(current_action, current_architecture, selected_kind_ids, other = {}):
	if current_action == MilitaryKindList.Action.PRODUCE_EQUIPMENT:
		var selected_person_ids = other['selected_person_ids']
		var a = military_kinds[selected_kind_ids[0]].id
		for id in selected_person_ids:
			var p = persons[id]
			p.set_working_task(Person.Task.PRODUCE_EQUIPMENT)
			p.set_produce_equipment(a)
		
func _on_attached_army_selected(current_action, current_architecture, selected_army_ids, other = {}):
	if current_action == AttachedArmyList.Action.DETACH:
		var army = attached_armies[selected_army_ids[0]]
		army.get_officers_list()[0].remove_attached_army()
	elif current_action == AttachedArmyList.Action.CREATE_TROOP:
		var army = attached_armies[selected_army_ids[0]]
		var troop = army.get_creating_troop(self)
		call_deferred("emit_signal", "create_troop_from_attached_army_select_position", current_architecture, troop)
	
func on_architecture_toggle_auto_task(current_architecture):
	current_architecture.auto_task = !current_architecture.auto_task

func _on_PositionSelector_create_troop(arch, troop, position):
	create_troop(arch, troop, position)

	
func create_troop(arch, troop, position) -> Troop:
	var scene = preload("Military/Troop.tscn")
	var instance = scene.instantiate()
	instance.scenario = self

	var in_experience = 0
	if troop is AttachedArmy:
		in_experience = troop.experience
	
	var id = troops.keys().max()
	if id == null:
		id = 1
	else:
		id = id + 1
	instance.create_troop_set_data(id, arch, troop.military_kind, troop.naval_military_kind, troop.quantity, troop.morale, troop.combativity, troop.persons[0].attached_army, position)
	
	for p in troop.persons:
		instance.add_person(p)
		p.clear_working_task()

	instance.set_scenario(self)
	troops[instance.id] = instance
	call_deferred("add_child", instance)
	instance.add_to_group(GROUP_GAME_INSTANCES)
	
	__connect_signals_for_creating_troop(instance)
	
	return instance


func _on_PositionSelector_move_troop(troop, position):
	troop.set_move_order(position)

func _on_PositionSelector_enter_troop(troop, position):
	troop.set_enter_order(position)
	
func _on_PositionSelector_follow_troop(troop, position):
	troop.set_follow_order(get_troop_at_position(position))
	
func _on_PositionSelector_attack_troop(troop, position):
	troop.set_attack_order(get_troop_at_position(position), get_architecture_at_position(position))

func _on_MainCamera_camera_moved(camera_rect: Rect2, zoom: Vector2):
	call_deferred("emit_signal", "scenario_camera_moved", camera_rect, zoom, self)
	_update_position_label(get_viewport().get_mouse_position())
	
func _on_PositionSelector_select_stunt_target(troop, stunt, position):
	$GameRecordCreator._on_troop_prepare_start_stunt(troop, stunt)
	var target_troop = get_troop_at_position(position)
	assert(target_troop != null)
	var stunt_level = troop.get_leader().stunts[stunt]
	troop.set_activate_stunt_order(stunt, stunt_level, target_troop)

func _on_troop_move_clicked(troop):
	$PositionSelector._on_select_troop_move_to(troop)
	
func _on_troop_follow_clicked(troop):
	$PositionSelector._on_select_troop_follow(troop)
	
func _on_troop_attack_clicked(troop):
	$PositionSelector._on_select_troop_attack(troop)
	
func _on_troop_stunt_clicked(troop, stunt):
	if stunt.target_range <= 0:
		$GameRecordCreator._on_troop_prepare_start_stunt(troop, stunt)
		var stunt_level = troop.get_leader().stunts[stunt]
		troop.set_activate_stunt_order(stunt, stunt_level, troop)
	else:
		$PositionSelector._on_select_troop_stunt_target(troop, stunt)
	
func _on_troop_enter_clicked(troop):
	$PositionSelector._on_select_troop_enter(troop)
	
func _on_troop_occupy_clicked(troop):
	troop.occupy()
	
func _on_focus_camera(position):
	$MainCamera.move_to(position)
	
func _on_confirm_transport_resources(from_architecture, to_architecture, to_transport_fund, to_transport_food, to_transport_troop, to_transport_equipments):
	var to_transport_equipments_id_key = {}
	for e in to_transport_equipments:
		to_transport_equipments_id_key[e.id] = to_transport_equipments[e]
	from_architecture.transport_resources(to_architecture, to_transport_fund, to_transport_food, to_transport_troop, to_transport_equipments_id_key)
	
########################################
#         Other signal Logic           #
########################################
var __day_passed_sec = Time.get_ticks_msec()

func _on_day_passed():
	# auto save
	turn_passed += 1
	if GameConfig.auto_save and int(turn_passed) % int(GameConfig.auto_save_interval) == 0:
		var path = "user://Saves/_AutoSaves"
		var dir = Directory.new()
		if not dir.dir_exists(path):
			dir.make_dir_recursive(path)
		dir.open(path)

		var save_id = int(turn_passed) / int(GameConfig.auto_save_interval) % int(GameConfig.auto_save_file_count)
		_save_data(path + "/_Auto" + str(save_id))
	
	# run days
	if GameConfig._use_threads:
		__on_day_passed_threaded()
	else:
		# run Troops
		var troop_queue = TroopQueue.new(troops.values())
		var troop_queue_result = troop_queue.execute()
		if troop_queue_result:
			await troop_queue_result.completed
		if Time.get_ticks_msec() - __day_passed_sec >= GameConfig.day_passed_interrupt_time:
			await get_tree().idle_frame
		__day_passed_sec = Time.get_ticks_msec()
		
		# run Factions
		var last_faction = current_faction
		for faction in factions.values():
			if faction._destroyed:
				continue
			current_faction = faction
			call_deferred("emit_signal", "current_faction_set", current_faction)
			ai.run_faction(faction, self)
			if Time.get_ticks_msec() - __day_passed_sec >= GameConfig.day_passed_interrupt_time:
				await get_tree().idle_frame
			__day_passed_sec = Time.get_ticks_msec()
			
		current_faction = last_faction
		call_deferred("emit_signal", "current_faction_set", current_faction)
		for faction in factions.values():
			if not faction._destroyed:
				faction.day_event()
			
		for troop in troops.values():
			if not troop._destroyed:
				troop.day_event()
				
		for person in persons.values():
			if person.alive:
				person.day_event()
		
		await get_tree().idle_frame
		call_deferred("emit_signal", "all_faction_finished")
		_on_architecture_survey_updated(null)

var __day_passed_finished = false
var _day_passed_thread = Thread.new()
func __on_day_passed_threaded():
	var troop_queue = TroopQueue.new(troops.values())
	var troop_queue_result = troop_queue.execute()
	if troop_queue_result:
		await troop_queue_result.completed

	__day_passed_finished = false
	_day_passed_thread.start(Callable(self,"___on_day_passed_thread").bind(0))

	while not __day_passed_finished:
		await get_tree().idle_frame
		
	_day_passed_thread.wait_to_finish()

	call_deferred("emit_signal", "all_faction_finished")
	_on_architecture_survey_updated(null)


func ___on_day_passed_thread(_unused):
	# run Factions
	var last_faction = current_faction
	for faction in factions.values():
		if faction._destroyed:
			continue
		current_faction = faction
		call_deferred("emit_signal", "current_faction_set", current_faction)
		ai.run_faction(faction, self)
		
	current_faction = last_faction
	call_deferred("emit_signal", "current_faction_set", current_faction)

	# run day event
	for faction in factions.values():
		if not faction._destroyed:
			faction.day_event()

	var all_troops = troops.values()
	for troop in all_troops:
		if not troop._destroyed:
			troop.day_event()
		else:
			remove_troop(troop)

	for person in persons.values():
		if person.alive:
			person.day_event()
	
	__day_passed_finished = true

	
func _on_month_passed(_month):
	for faction in factions.values():
		faction.month_event()
		
	for person in persons.values():
		person.month_event()
	

func _on_all_loaded():
	call_deferred("emit_signal", "current_faction_set", current_faction)
	var camera = $MainCamera as MainCamera
	call_deferred("emit_signal", "scenario_camera_moved", camera.get_viewing_rect(), camera.zoom, self)
	
	for a in architectures:
		_on_architecture_faction_changed(architectures[a])
	
	for t in troops:
		call_deferred("emit_signal", "scenario_troop_created", self, troops[t])
		
func _on_troop_position_changed(troop, old_pos, new_pos):
	call_deferred("emit_signal", "scenario_troop_position_changed", self, troop, old_pos, new_pos)
	
func _on_troop_created(troop, position):
	if not _loading_scenario:
		$GameRecordCreator.create_troop(troop, position)
	call_deferred("emit_signal", "scenario_troop_created", self, troop)
	
func _on_troop_removed(troop):
	call_deferred("emit_signal", "scenario_troop_removed", self, troop)

func _on_person_available(person, reason, reason_person):
	if reason == Person.AvailableReason.BROTHER:
		$GameRecordCreator.person_available_by_brother(person, reason_person)
	elif reason == Person.AvailableReason.SPOUSE:
		$GameRecordCreator.person_available_by_spouse(person, reason_person)
	elif reason == Person.AvailableReason.CHILDREN:
		$GameRecordCreator.person_available_by_children(person, reason_person)
	elif reason == Person.AvailableReason.SIBLING:
		$GameRecordCreator.person_available_by_sibling(person, reason_person)

########################################
#                Process               #
########################################

func _process(delta):
	if _architecture_clicked != null and _troop_clicked == null:
		call_deferred("emit_signal", "architecture_clicked", _architecture_clicked, _clicked_at.x, _clicked_at.y, _right_clicked)
	elif _architecture_clicked == null and _troop_clicked != null:
		call_deferred("emit_signal", "troop_clicked", _troop_clicked, _clicked_at.x, _clicked_at.y, _right_clicked)
	elif _architecture_clicked != null and _troop_clicked != null:
		call_deferred("emit_signal", "architecture_and_troop_clicked", _architecture_clicked, _troop_clicked, _clicked_at.x, _clicked_at.y, _right_clicked)
	elif __right_click_on_blank_detected:
		call_deferred("emit_signal", "empty_space_right_clicked")
	
	__right_click_on_blank_detected = false
	_architecture_clicked = null
	_troop_clicked = null
	
	
######################################
#               Getters              #
######################################

func get_persons_from_ids(ids):
	var result = []
	for p in ids:
		result.append(persons[p])
	return result
	
func get_player_factions():
	var arr = []
	for f in factions:
		if factions[f].player_controlled:
			arr.append(f)
	return arr

func get_terrain_at_position(position):
	var terrain_id = $Map._get_terrain_id_at_position(position)
	if terrain_id >= 0:
		for t in terrain_details:
			for id in terrain_details[t].terrain_ids:
				if int(id) == int(terrain_id):
					return terrain_details[t]
		assert(false) #,'Should have terrain detail set for all tile ID. Not found for ID ' + str(terrain_id))
	return null
	
func get_ai_path_available_movement_kinds(start_arch, end_arch):
	var paths = start_arch.adjacent_archs[end_arch.id]
	return paths.keys()

func get_ai_path(movement_kind_id, start_arch, end_arch):
	var paths = start_arch.adjacent_archs[end_arch.id]
	for mk in paths:
		if mk == movement_kind_id:
			return paths[mk]
	assert(false) #,'Cannot find AIPath from ' + start_arch.get_name() + ' to ' + end_arch.get_name() + ' for movement kind ' + str(movement_kind_id))

# TODO may need cache
func get_troop_at_position(position):
	for t in troops:
		if troops[t].map_position == position:
			return troops[t]
	return null

# TODO may need cache
func get_architecture_at_position(position):
	for a in architectures:
		if architectures[a].map_position == position:
			return architectures[a]
	return null
	
func describe_position(position):
	var a = get_architecture_at_position(position)
	if a != null:
		return a.get_name()
	var t = get_troop_at_position(position)
	if t != null:
		return t.get_name()
	var terrain = get_terrain_at_position(position)
	return terrain.get_name() + str(position)

func get_living_persons():
	var list = []
	for i in persons:
		var p = persons[i]
		if p.get_location() != null:
			list.append(p)
	return list
	
func get_year():
	return ($DateRunner as DateRunner).year
	
func get_season():
	return ($DateRunner as DateRunner).get_season()
	
########################################
#          Data Management             #
########################################

func remove_troop(item):
	troops.erase(item.id)
	
func remove_faction(item):
	for s in item.get_sections():
		s.destroy()
		sections.erase(s.id)
	factions.erase(item.id)
	
func add_attached_army(army):
	attached_armies[army.id] = army

func remove_attached_army(army):
	attached_armies.erase(army.id)

########################################
#                Misc.                 #
########################################

func _update_position_label(mouse_position):
	var rect = get_camera_viewing_rect()
	var zoom = get_camera_zoom()
	var map_x = int(rect.position.x / tile_size + mouse_position.x * zoom.x / tile_size)
	var map_y = int(rect.position.y / tile_size + mouse_position.y * zoom.y / tile_size)
	
	if map_x < 0 or map_x > map_size.x: 
		return
	if map_y < -1 or map_y > map_size.y:
		return
	
	var map_pos = Vector2(map_x, map_y)
	var terrain = get_terrain_at_position(map_pos)
	if terrain != null:
		call_deferred("emit_signal", "mouse_moved_to_map_position", map_pos, terrain)

func is_observer():
	for f in factions:
		if factions[f].player_controlled:
			return false
	return true
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_update_position_label(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			__right_click_on_blank_detected = true
		

