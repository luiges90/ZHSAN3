extends Node2D
class_name PositionSelector

func _on_create_troop(arch, troop):
	var item = preload("PositionSelectItem.tscn")
	var instance = item.instance()
	
	instance.position = arch.position
	instance.scale = Vector2(SharedData.TILE_SIZE / 100.0, SharedData.TILE_SIZE / 100.0)
	
	add_child(instance)
