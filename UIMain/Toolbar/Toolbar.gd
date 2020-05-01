extends Panel
class_name Toolbar

var _running = false

signal start_date_runner
signal stop_date_runner
signal system_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _get_value():
	return int($DateRunner/TensDigit/Text10.text) * 10 + \
		int($DateRunner/UnitDigit/Text.text)

func _change_digit(node, change):
	var i = int(node.text) + change
	if i > 9:
		i = 0
	if i < 0:
		i = 9
	node.text = str(i)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_SPACE:
			if $DateRunner/UnitDigit/Text.text == '0' and $DateRunner/TensDigit/Text10.text == '0':
				$DateRunner/TensDigit/Text10.text = '0'
				$DateRunner/UnitDigit/Text.text = '1'
			_on_Play_pressed()
		elif not _running:
			match event.scancode:
				KEY_0:
					$DateRunner/TensDigit/Text10.text = '1'
					$DateRunner/UnitDigit/Text.text = '0'
					_on_Play_pressed()
				KEY_1:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '1'
					_on_Play_pressed()
				KEY_2:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '2'
					_on_Play_pressed()
				KEY_3:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '3'
					_on_Play_pressed()
				KEY_4:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '4'
					_on_Play_pressed()
				KEY_5:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '5'
					_on_Play_pressed()
				KEY_6:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '6'
					_on_Play_pressed()
				KEY_7:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '7'
					_on_Play_pressed()
				KEY_8:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '8'
					_on_Play_pressed()
				KEY_9:
					$DateRunner/TensDigit/Text10.text = '0'
					$DateRunner/UnitDigit/Text.text = '9'
					_on_Play_pressed()
				KEY_F1:
					$DateRunner/TensDigit/Text10.text = '3'
					$DateRunner/UnitDigit/Text.text = '0'
					_on_Play_pressed()
				KEY_F2:
					$DateRunner/TensDigit/Text10.text = '6'
					$DateRunner/UnitDigit/Text.text = '0'
					_on_Play_pressed()
				KEY_F3:
					$DateRunner/TensDigit/Text10.text = '9'
					$DateRunner/UnitDigit/Text.text = '0'
					_on_Play_pressed()

func _on_Up10_pressed():
	_change_digit($DateRunner/TensDigit/Text10, 1)

func _on_Down10_pressed():
	_change_digit($DateRunner/TensDigit/Text10, -1)

func _on_Up_pressed():
	_change_digit($DateRunner/UnitDigit/Text, 1)

func _on_Down_pressed():
	_change_digit($DateRunner/UnitDigit/Text, -1)


func _on_Play_pressed():
	if _running:
		_running = false
		_set_play_button_texture_to_play()
		emit_signal("stop_date_runner")
	else:
		var value = _get_value()
		if value > 0:
			_running = true
			_set_play_button_texture_to_pause()
			emit_signal("start_date_runner", value)
		
func _on_Stop_pressed():
	_running = false
	$DateRunner/TensDigit/Text10.text = '0'
	$DateRunner/UnitDigit/Text.text = '0'
	_set_play_button_texture_to_play()
	emit_signal("stop_date_runner")


func _set_play_button_texture_to_play():
	$DateRunner/Play.texture_normal = preload("Play.png")
	$DateRunner/Play.texture_hover = preload("PlaySelected.png")
	$DateRunner/Play.texture_pressed = preload("Play.png")
	for node in get_tree().get_nodes_in_group("date_runner_change_digit"):
		node.disabled = false
	
func _set_play_button_texture_to_pause():
	$DateRunner/Play.texture_normal = preload("Pause.png")
	$DateRunner/Play.texture_hover = preload("PauseSelected.png")
	$DateRunner/Play.texture_pressed = preload("Pause.png")
	for node in get_tree().get_nodes_in_group("date_runner_change_digit"):
		node.disabled = true
		
func _on_day_passed():
	var unit = int($DateRunner/UnitDigit/Text.text)
	if unit <= 0:
		var tens = int($DateRunner/TensDigit/Text10.text)
		if tens > 0:
			$DateRunner/TensDigit/Text10.text = str(int($DateRunner/TensDigit/Text10.text) - 1)
			$DateRunner/UnitDigit/Text.text = '9'
		else:
			# this path should not happen
			_running = false
			_set_play_button_texture_to_play()
			emit_signal("stop_date_runner")
	else:
		$DateRunner/UnitDigit/Text.text = str(int($DateRunner/UnitDigit/Text.text) - 1)
		var units = int($DateRunner/UnitDigit/Text.text)
		var tens = int($DateRunner/TensDigit/Text10.text)
		if units <= 0 and tens <= 0:
			_running = false
			_set_play_button_texture_to_play()
			emit_signal("stop_date_runner")


func _on_System_pressed():
	$Select.play()
	emit_signal("system_clicked")
