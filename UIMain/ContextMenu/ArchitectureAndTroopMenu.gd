extends VBoxContainer
class_name ArchitectureAndTroopMenu

var showing_arch 
var showing_troop
var mx
var my

signal architecture_clicked
signal troop_clicked

var _opening_list

func show_menu(arch, troop, mouse_x, mouse_y):	
	if GameConfig.se_enabled:
		($OpenSound as AudioStreamPlayer).play()
	showing_arch = arch
	showing_troop = troop
	
	margin_left = mouse_x
	margin_top = mouse_y
	mx = mouse_x
	my = mouse_y
	
	$Architecture.text = showing_arch.get_name()
	$Troop.text = showing_troop.get_name()
	
	show()


func _on_Architecture_pressed():
	if GameConfig.se_enabled:
		($ClickSound as AudioStreamPlayer).play()
	emit_signal("architecture_clicked", showing_arch, mx, my)
	_opening_list = true
	hide()


func _on_Troop_pressed():
	if GameConfig.se_enabled:
		($ClickSound as AudioStreamPlayer).play()
	emit_signal("troop_clicked", showing_troop, mx, my)
	_opening_list = true
	hide()


func _on_ArchitectureAndTroopMenu_hide():
	if GameConfig.se_enabled and not _opening_list:
		($CloseSound as AudioStreamPlayer).play()
	_opening_list = false
