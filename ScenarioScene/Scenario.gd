extends Node
class_name Scenario

onready var tile_size: int = $Map.tile_size
onready var map_size: Vector2 = $Map.map_size

var ai: AI

var current_faction

var architecture_kinds = Dictionary() setget forbidden

var factions = Dictionary() setget forbidden
var architectures = Dictionary() setget forbidden
var persons = Dictionary() setget forbidden

signal current_faction_set
signal scenario_loaded

signal architecture_clicked
signal architecture_survey_updated

signal all_faction_finished

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
		SharedData.loading_file_path = "user://Scenarios/194QXGJ-qh"
	_load_data(SharedData.loading_file_path)
	
	var player_factions = get_player_factions()
	if player_factions.size() > 0:
		var fid = player_factions[0]
		camera.position = factions[fid].get_architectures()[0].position - camera.get_viewport_rect().size / 2
		camera.emit_signal("camera_moved", camera.position, camera.position + camera.get_viewport_rect().size * camera.zoom)
	
	$DateRunner.connect("day_passed", self, "_on_day_passed")
	$DateRunner.connect("month_passed", self, "_on_month_passed")
	
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
			"GameData": {
				"Year": date.year,
				"Month": date.month,
				"Day": date.day
			}
		}
	))
	file.close()
	
	file.open(path + "/ArchitectureKinds.json", File.WRITE)
	file.store_line(to_json(__save_items(architecture_kinds)))
	file.close()
	
	file.open(path + "/Factions.json", File.WRITE)
	file.store_line(to_json(__save_items(factions)))
	file.close()
	
	file.open(path + "/Architectures.json", File.WRITE)
	file.store_line(to_json(__save_items(architectures)))
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
	var file = File.new()
	file.open(path + "/Scenario.json", File.READ)
	
	var obj = parse_json(file.get_as_text())
	
	var date = $DateRunner as DateRunner
	date.year = obj["GameData"]["Year"]
	date.month = obj["GameData"]["Month"]
	date.day = obj["GameData"]["Day"]
	var current_faction_id = obj["CurrentFactionId"]
	file.close()
	
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
	file.close()
	
	file.open(path + "/Factions.json", File.READ)
	obj = parse_json(file.get_as_text())
	for item in obj:
		var instance = Faction.new()
		__load_item(instance, item, factions)
		for id in item["ArchitectureList"]:
			instance.add_architecture(architectures[int(id)])
			
	current_faction = factions[int(current_faction_id)]
	file.close()
	
	emit_signal("scenario_loaded")

	
func __load_item(instance, item, add_to_list):
	instance.scenario = self
	instance.load_data(item)
	add_to_list[instance.id] = instance
	add_child(instance)
	
func get_player_factions():
	var arr = []
	for f in factions:
		if factions[f].player_controlled:
			arr.append(f)
	return arr

func _on_all_loaded():
	emit_signal("current_faction_set", current_faction)
	
func _on_architecture_clicked(arch, mx, my):
	emit_signal("architecture_clicked", arch, mx, my)
	
func _on_architecture_survey_updated(arch):
	emit_signal("architecture_survey_updated", arch)
	
func _on_architecture_person_selected(task, current_architecture, selected_person_ids):
	var p = []
	for id in selected_person_ids:
		p.append(persons[id])
	match task:
		Person.Task.AGRICULTURE: architectures[current_architecture].set_person_task(task, p)
		Person.Task.COMMERCE: architectures[current_architecture].set_person_task(task, p)
		Person.Task.MORALE: architectures[current_architecture].set_person_task(task, p)
		Person.Task.ENDURANCE: architectures[current_architecture].set_person_task(task, p)
		# Person.Task.MOVE:

func _on_day_passed():
	var last_faction = current_faction
	for faction in factions.values():
		current_faction = faction
		emit_signal("current_faction_set", current_faction)
		if not faction.player_controlled:
			ai.run_faction(faction, self)
	current_faction = last_faction
	emit_signal("current_faction_set", current_faction)
	for faction in factions.values():
		faction.day_event()
	yield(get_tree(), "idle_frame")
	emit_signal("all_faction_finished")
	
func _on_month_passed():
	for faction in factions.values():
		faction.month_event()
	
