extends Node
class_name Scenario

onready var tile_size: int = $Map.tile_size
onready var map_size: Vector2 = $Map.map_size

const GROUP_GAME_INSTANCES = "game_instances"

var ai: AI

var current_faction

var terrain_details = Dictionary() setget forbidden
var movement_kinds = Dictionary() setget forbidden
var architecture_kinds = Dictionary() setget forbidden
var military_kinds = Dictionary() setget forbidden

var ai_paths = Dictionary() setget forbidden

var factions = Dictionary() setget forbidden
var sections = Dictionary() setget forbidden
var architectures = Dictionary() setget forbidden
var persons = Dictionary() setget forbidden
var troops = Dictionary() setget forbidden

var current_scenario_name = null

var _architecture_clicked
var _troop_clicked
var _clicked_at: Vector2

signal current_faction_set
signal scenario_loaded

signal architecture_clicked
signal architecture_survey_updated
signal troop_clicked
signal architecture_and_troop_clicked

signal all_faction_finished

signal camera_moved
signal mouse_moved_to_map_position

func forbidden(x):
	assert(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	var ai_script = preload("AI/AI.gd")
	ai = ai_script.new()
	
	var camera = $MainCamera as MainCamera
	camera.scenario = self
	($DateRunner as DateRunner).scenario = self
	
	if SharedData.loading_file_path == null:
		SharedData.loading_file_path = "res://Scenarios/194QXGJ-qh"
		current_scenario_name = "194QXGJ-qh"
	else: 
		var pos = SharedData.loading_file_path.find('Scenarios')
		if pos >= 0:
			current_scenario_name = SharedData.loading_file_path.substr(pos + 10)
	_load_data(SharedData.loading_file_path)
	
	var player_factions = get_player_factions()
	if player_factions.size() > 0:
		var fid = player_factions[0]
		camera.position = factions[fid].get_architectures()[0].position
		camera.emit_signal("camera_moved", camera.get_viewing_rect(), camera.zoom)
	
	$DateRunner.connect("day_passed", self, "_on_day_passed")
	$DateRunner.connect("month_passed", self, "_on_month_passed")
	
	
	
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
		_load_data(path)
	
func _save_data(path):
	var dir = Directory.new()
	dir.make_dir(path)
	
	var date = $DateRunner as DateRunner
	
	var file = File.new()
	file.open(path + "/Scenario.json", File.WRITE)
	file.store_line(to_json(
		{
			"CurrentFactionId": current_faction.id,
			"Scenario": current_scenario_name,
			"GameData": {
				"Year": date.year,
				"Month": date.month,
				"Day": date.day
			}
		}
	))
	file.close()
	
	file.open(path + "/TerrainDetails.json", File.WRITE)
	file.store_line(to_json(__save_items(terrain_details)))
	file.close()
	
	file.open(path + "/MovementKinds.json", File.WRITE)
	file.store_line(to_json(__save_items(movement_kinds)))
	file.close()
	
	file.open(path + "/MilitaryKinds.json", File.WRITE)
	file.store_line(to_json(__save_items(military_kinds)))
	file.close()
	
	file.open(path + "/ArchitectureKinds.json", File.WRITE)
	file.store_line(to_json(__save_items(architecture_kinds)))
	file.close()
	
	file.open(path + "/Factions.json", File.WRITE)
	file.store_line(to_json(__save_items(factions)))
	file.close()
	
	file.open(path + "/Sections.json", File.WRITE)
	file.store_line(to_json(__save_items(sections)))
	file.close()
	
	file.open(path + "/Architectures.json", File.WRITE)
	file.store_line(to_json(__save_items(architectures)))
	file.close()
	
	file.open(path + "/Troops.json", File.WRITE)
	file.store_line(to_json(__save_items(troops)))
	file.close()
	
	file.open(path + "/Persons.json", File.WRITE)
	file.store_line(to_json(__save_items(persons)))
	file.close()

	
func __save_items(d: Dictionary):
	var arr = []
	for item in d.values():
		arr.push_back(item.save_data())
	return arr

func _load_data(path):
	for n in get_tree().get_nodes_in_group(GROUP_GAME_INSTANCES):
		remove_child(n)
		n.queue_free()
	
	var file = File.new()
	file.open(path + "/Scenario.json", File.READ)
	
	var obj = parse_json(file.get_as_text())
	
	var date = $DateRunner as DateRunner
	date.year = obj["GameData"]["Year"]
	date.month = obj["GameData"]["Month"]
	date.day = obj["GameData"]["Day"]
	var current_faction_id = obj["CurrentFactionId"]
	var current_name = obj.get("Scenario")
	if current_name != null:
		current_scenario_name = current_name
	file.close()
	
	file.open(path + "/TerrainDetails.json", File.READ)
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = TerrainDetail.new()
		__load_item(instance, item, terrain_details)
	file.close()
	
	file.open(path + "/MovementKinds.json", File.READ)
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = MovementKind.new()
		__load_item(instance, item, movement_kinds)
	file.close()
	
	for kind in movement_kinds:
		var err = file.open(path + "/paths/" + str(kind) + '.json', File.READ)
		if err != OK:
			file.open("res://Scenarios/" + current_scenario_name + "/paths/" + str(kind) + '.json', File.READ)
		obj = parse_json(file.get_as_text())
		var ai_path = AIPaths.new()
		ai_path.load_data(obj)
		ai_paths[kind] = ai_path
		file.close()
		
	file.open(path + "/MilitaryKinds.json", File.READ)
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = MilitaryKind.new()
		__load_item(instance, item, military_kinds)
	file.close()
	SharedData._load_troop_sprite_frames(military_kinds.values())
	
	file.open(path + "/ArchitectureKinds.json", File.READ)
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = ArchitectureKind.new()
		__load_item(instance, item, architecture_kinds)
	file.close()

	file.open(path + "/Persons.json", File.READ)
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = Person.new()
		__load_item(instance, item, persons)
	file.close()
	
	file.open(path + "/Architectures.json", File.READ)
	var architecture_scene = preload("Architecture/Architecture.tscn")
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = architecture_scene.instance()
		instance.connect("architecture_clicked", self, "_on_architecture_clicked")
		instance.connect("architecture_survey_updated", self, "_on_architecture_survey_updated")
		__load_item(instance, item, architectures)
		for id in item["PersonList"]:
			instance.add_person(persons[int(id)])
		
		instance.setup_after_load()
	file.close()
	for item in architectures:
		architectures[item].set_adjacency(architectures, ai_paths)
		
	file.open(path + "/Troops.json", File.READ)
	var troop_scene = preload("Military/Troop.tscn")
	obj = parse_json(file.get_as_text())
	var troop_json = {}
	for item in obj:
		var instance = troop_scene.instance()
		instance.connect("troop_clicked", self, "_on_troop_clicked")
		__load_item(instance, item, troops)
		for id in item["PersonList"]:
			instance.add_person(persons[int(id)])
		troop_json[instance.id] = item
	for tid in troops:
		var order_type = troop_json[tid]["_CurrentOrderType"]
		var order_target_raw = troop_json[tid]["_CurrentOrderTarget"]
		var order_target_type = troop_json[tid]["_CurrentOrderTargetType"]
		if order_target_type == "Position":
			troops[tid].set_move_order(Util.load_position(order_target_raw))
		elif order_target_type == "Architecture":
			var arch = architectures[int(order_target_raw)]
			troops[tid].set_attack_order(null, arch)
		elif order_target_type == "Troop":
			var troop = troops[int(order_target_raw)]
			if order_type == Troop.OrderType.ATTACK:
				troops[tid].set_attack_order(troop, null)
			elif order_type == Troop.OrderType.FOLLOW:
				troops[tid].set_follow_order(troop)
		
	
	file.close()
	
	file.open(path + "/Sections.json", File.READ)
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = Section.new()
		__load_item(instance, item, sections)
		for id in item["ArchitectureList"]:
			instance.add_architecture(architectures[int(id)])
		for id in item["TroopList"]:
			instance.add_troop(troops[int(id)])
	
	file.open(path + "/Factions.json", File.READ)
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = Faction.new()
		__load_item(instance, item, factions)
		for id in item["SectionList"]:
			instance.add_section(sections[int(id)])
	file.close()
	
	__handle_player_faction(current_faction_id)
	emit_signal("scenario_loaded")

	
func __load_item(instance, item, add_to_list):
	instance.scenario = self
	instance.load_data(item)
	add_to_list[int(instance.id)] = instance
	if instance is Architecture or instance is Troop:
		instance.add_to_group(GROUP_GAME_INSTANCES)
		add_child(instance)
	
func __handle_player_faction(current_faction_id):
	if SharedData.starting_faction_id != null:
		current_faction = factions[int(SharedData.starting_faction_id)]
		current_faction.player_controlled = true
	else:
		current_faction = factions[int(current_faction_id)]

########################################
#           UI signal handling         #
########################################
	
func _on_architecture_clicked(arch, mx, my):
	_architecture_clicked = arch
	_clicked_at = Vector2(mx, my)
	
func _on_architecture_survey_updated(arch):
	emit_signal("architecture_survey_updated", arch)
	
func _on_troop_clicked(troop, mx, my):
	_troop_clicked = troop
	_clicked_at = Vector2(mx, my)

	
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

func _on_architecture_selected(task, current_architecture, selected_arch_ids, other = {}):
	var selected_person_ids = other['selected_person_ids']
	var a = architectures[selected_arch_ids[0]]
	for id in selected_person_ids:
		var p = persons[id]
		p.move_to_architecture(a)
		
func _on_military_kind_selected(task, current_architecture, selected_kind_ids, other = {}):
	var selected_person_ids = other['selected_person_ids']
	var a = military_kinds[selected_kind_ids[0]].id
	for id in selected_person_ids:
		var p = persons[id]
		p.set_working_task(Person.Task.PRODUCE_EQUIPMENT)
		p.set_produce_equipment(a)
		
func on_architecture_toggle_auto_task(current_architecture):
	current_architecture.auto_task = !current_architecture.auto_task

func _on_PositionSelector_create_troop(arch, troop, position):
	create_troop(arch, troop, position)
	
func create_troop(arch, troop, position) -> Troop:
	var scene = preload("Military/Troop.tscn")
	var instance = scene.instance()
	instance.connect("troop_clicked", self, "_on_troop_clicked")
	instance.connect("occupy_architecture", $GameRecordCreator, "_on_troop_occupy_architecture")
	instance.connect("destroyed", $GameRecordCreator, "_on_troop_destroyed")
	for p in troop.persons:
		instance.add_person(p)

	var id = troops.keys().max()
	if id == null:
		id = 1
	else:
		id = id + 1
	instance.scenario = self
	instance.create_troop_set_data(id, arch, troop.military_kind, troop.quantity, troop.morale, troop.combativity, position)
	troops[instance.id] = instance
	add_child(instance)
	instance.add_to_group(GROUP_GAME_INSTANCES)
	
	$GameRecordCreator.create_troop(instance, position)
	
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
	emit_signal("camera_moved", camera_rect, zoom)
	_update_position_label(get_viewport().get_mouse_position())
	

func _on_troop_move_clicked(troop):
	$PositionSelector._on_select_troop_move_to(troop)
	
func _on_troop_follow_clicked(troop):
	$PositionSelector._on_select_troop_follow(troop)
	
func _on_troop_attack_clicked(troop):
	$PositionSelector._on_select_troop_attack(troop)
	
func _on_troop_enter_clicked(troop):
	$PositionSelector._on_select_troop_enter(troop)
	
func _on_troop_occupy_clicked(troop):
	troop.occupy()
	
func _on_focus_camera(position):
	$MainCamera.move_to(position)
	
########################################
#         Other signal Logic           #
########################################

func _on_day_passed():
	# run Troops
	var troop_queue = TroopQueue.new(troops.values())
	var troop_queue_result = troop_queue.execute()
	if troop_queue_result:
		yield(troop_queue_result, "completed")
	
	# run Factions
	var last_faction = current_faction
	for faction in factions.values():
		current_faction = faction
		emit_signal("current_faction_set", current_faction)
		ai.run_faction(faction, self)
	current_faction = last_faction
	emit_signal("current_faction_set", current_faction)
	for faction in factions.values():
		faction.day_event()
		
	for troop in troops.values():
		troop.day_event()
	
	yield(get_tree(), "idle_frame")
	emit_signal("all_faction_finished")
	
func _on_month_passed():
	for faction in factions.values():
		faction.month_event()
	

func _on_all_loaded():
	emit_signal("current_faction_set", current_faction)


########################################
#                Process               #
########################################

func _process(delta):
	if _architecture_clicked != null and _troop_clicked == null:
		emit_signal("architecture_clicked", _architecture_clicked, _clicked_at.x, _clicked_at.y)
	elif _architecture_clicked == null and _troop_clicked != null:
		emit_signal("troop_clicked", _troop_clicked, _clicked_at.x, _clicked_at.y)
	elif _architecture_clicked != null and _troop_clicked != null:
		emit_signal("architecture_and_troop_clicked", _architecture_clicked, _troop_clicked, _clicked_at.x, _clicked_at.y)
	_architecture_clicked = null
	_troop_clicked = null
	
########################################
#           Data Retrieval             #
########################################

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
		assert(false, 'Should have terrain detail set for all tile ID. Not found for ID ' + str(terrain_id))
	return null
	
func get_ai_path_available_movement_kinds(start_arch, end_arch):
	var paths = start_arch.adjacent_archs[end_arch.id]
	return paths.keys()

func get_ai_path(movement_kind_id, start_arch, end_arch):
	var paths = start_arch.adjacent_archs[end_arch.id]
	for mk in paths:
		if mk == movement_kind_id:
			return paths[mk]
	assert(false, 'Cannot find AIPath from ' + start_arch.get_name() + ' to ' + end_arch.get_name() + ' for movement kind ' + str(movement_kind_id))

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

	
########################################
#          Data Management             #
########################################

func remove_troop(item):
	troops.erase(item.id)

########################################
#                Misc.                 #
########################################

func _update_position_label(mouse_position):
	var rect = get_camera_viewing_rect()
	var zoom = get_camera_zoom()
	var map_x = int(rect.position.x / tile_size + mouse_position.x * zoom.x / tile_size)
	var map_y = int(rect.position.y / tile_size + mouse_position.y * zoom.y / tile_size)
	
	var map_pos = Vector2(map_x, map_y)
	var terrain = get_terrain_at_position(map_pos)
	if terrain != null:
		emit_signal("mouse_moved_to_map_position", map_pos, terrain)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_update_position_label(event.position)
		
		
