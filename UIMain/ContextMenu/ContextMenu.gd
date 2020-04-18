extends Control
class_name ContextMenu

var _confirming = false

func show():
	if GameConfig.se_enabled:
		$OpenSound.play()
	.show()


func _select_item():
	if GameConfig.se_enabled:
		$ClickSound.play()
	_confirming = true
	hide()


func _open_submenu():
	if GameConfig.se_enabled:
		($OpenSound as AudioStreamPlayer).play()
	_hide_submenus()
		

func _hide_submenus():
	pass


func _on_ContextMenu_hide():
	if not _confirming:
		if GameConfig.se_enabled:
			$CloseSound.play()
	_hide_submenus()
	_confirming = false
	
