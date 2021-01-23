extends ContextMenu
class_name ArchitectureAndTroopMenu

var showing_arch 
var showing_troop
var mx
var my

signal architecture_clicked
signal troop_clicked

var _opening_list

func show_menu(arch, troop, mouse_x, mouse_y, right_clicked):
	showing_arch = arch
	showing_troop = troop
	
	margin_left = mouse_x
	margin_top = mouse_y
	mx = mouse_x
	my = mouse_y
	
	$V/Architecture.text = showing_arch.get_name()
	$V/Troop.text = showing_troop.get_name()
	
	show()


func _on_Architecture_pressed():
	_select_item()
	call_deferred("emit_signal", "architecture_clicked", showing_arch, mx, my)


func _on_Troop_pressed():
	_select_item()
	call_deferred("emit_signal", "troop_clicked", showing_troop, mx, my)

