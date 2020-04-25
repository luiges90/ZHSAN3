extends Node2D
class_name PositionSelector

enum CurrentAction { CREATE_TROOP }
var current_action

var current_architecture
var current_troop

var _cancel = false

signal create_troop

func _process(delta):
	if _cancel:
		Util.delete_all_children(self)
		_cancel = false


func _on_create_troop(arch, troop):
	current_action = CurrentAction.CREATE_TROOP
	current_architecture = arch
	current_troop = troop
	_create_position_select_item(arch.map_position)
	_create_position_select_item(arch.map_position + Vector2.UP)
	_create_position_select_item(arch.map_position + Vector2.DOWN)
	_create_position_select_item(arch.map_position + Vector2.LEFT)
	_create_position_select_item(arch.map_position + Vector2.RIGHT)
	
	
func _create_position_select_item(position):
	var item = preload("PositionSelectItem.tscn")
	var instance = item.instance()
	
	instance.position = position * SharedData.TILE_SIZE
	instance.scale = Vector2(SharedData.TILE_SIZE / 100.0, SharedData.TILE_SIZE / 100.0)
	instance.connect("position_selected", self, "_on_position_selected", [position])
	
	add_child(instance)
	

func _on_cancel_ui():
	_cancel = true


func _on_position_selected(position):
	match current_action:
		CurrentAction.CREATE_TROOP:
			emit_signal("create_troop", current_architecture, current_troop, position)
