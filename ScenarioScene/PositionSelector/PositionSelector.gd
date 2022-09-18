extends Node2D
class_name PositionSelector

enum CurrentAction { CREATE_TROOP, MOVE_TROOP, ATTACK_TROOP, ENTER_TROOP, FOLLOW_TROOP, SELECT_STUNT_TARGET }
var current_action

var current_architecture
var current_troop
var current_stunt

var _cancel = false

signal create_troop
signal move_troop
signal enter_troop
signal follow_troop
signal attack_troop
signal select_stunt_target

func _process(delta):
	if _cancel:
		Util.delete_all_children(self)
		_cancel = false


func _on_create_troop(arch, troop):
	current_action = CurrentAction.CREATE_TROOP
	current_architecture = arch
	current_troop = troop
	
	var positions = arch.create_troop_positions()
	for p in positions:
		_create_position_select_item(p, Color.BLUE)


func _on_select_troop_move_to(troop):
	current_action = CurrentAction.MOVE_TROOP
	current_architecture = null
	current_troop = troop
	
	for pos in current_troop.get_movement_area():
		_create_position_select_item(pos, Color.BLUE)
		

func _on_select_troop_attack(troop):
	current_action = CurrentAction.ATTACK_TROOP
	current_architecture = null
	current_troop = troop
	
	var scen = current_troop.scenario
	for t in scen.troops:
		var target_troop = scen.troops[t]
		if target_troop != null and target_troop != troop and target_troop.get_belonged_faction() != troop.get_belonged_faction():
			_create_position_select_item(target_troop.map_position, Color.RED)
	for a in scen.architectures:
		var target_arch = scen.architectures[a]
		if target_arch != null and target_arch.get_belonged_faction() != troop.get_belonged_faction():
			_create_position_select_item(target_arch.map_position, Color.RED)
			


func _on_select_troop_enter(troop):
	current_action = CurrentAction.ENTER_TROOP
	current_architecture = null
	current_troop = troop
	
	var scen = current_troop.scenario
	for a in scen.architectures:
		var target_arch = scen.architectures[a]
		if target_arch != null and target_arch.get_belonged_faction() == troop.get_belonged_faction():
			_create_position_select_item(target_arch.map_position, Color.BLUE)


func _on_select_troop_follow(troop):
	current_action = CurrentAction.FOLLOW_TROOP
	current_architecture = null
	current_troop = troop
	
	var scen = current_troop.scenario
	for t in scen.troops:
		var target_troop = scen.troops[t]
		if target_troop != null and target_troop != troop:
			_create_position_select_item(target_troop.map_position, Color.YELLOW)

	
func _on_select_troop_stunt_target(troop, stunt):
	current_action = CurrentAction.SELECT_STUNT_TARGET
	current_architecture = null
	current_troop = troop
	current_stunt = stunt

	var valid_targets = stunt.get_valid_target_squares(troop)
	for t in valid_targets:
		_create_position_select_item(t, Color.RED)


func _create_position_select_item(position, color = Color.WHITE):
	var item = preload("PositionSelectItem.tscn")
	var instance = item.instantiate()
	
	instance.position = position * SharedData.TILE_SIZE
	instance.scale = Vector2(SharedData.TILE_SIZE / 100.0, SharedData.TILE_SIZE / 100.0)
	instance.connect("position_selected",Callable(self,"_on_position_selected").bind(position))
	instance.set_color(color)
	
	add_child(instance)
	

func _on_cancel_ui():
	_cancel = true


func _on_position_selected(position):
	match current_action:
		CurrentAction.CREATE_TROOP:
			call_deferred("emit_signal", "create_troop", current_architecture, current_troop, position)
		CurrentAction.MOVE_TROOP:
			call_deferred("emit_signal", "move_troop", current_troop, position)
		CurrentAction.ENTER_TROOP:
			call_deferred("emit_signal", "enter_troop", current_troop, position)
		CurrentAction.FOLLOW_TROOP:
			call_deferred("emit_signal", "follow_troop", current_troop, position)
		CurrentAction.ATTACK_TROOP:
			call_deferred("emit_signal", "attack_troop", current_troop, position)
		CurrentAction.SELECT_STUNT_TARGET:
			call_deferred("emit_signal", "select_stunt_target", current_troop, current_stunt, position)
