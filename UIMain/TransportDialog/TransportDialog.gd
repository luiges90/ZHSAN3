extends Panel
class_name TransportDialog

signal select_architecture
signal confirm_transport_resources

var from_architecture = null
var to_architecture = null
var to_transport_fund = 0
var to_transport_food = 0
var to_transport_troop = 0

func _on_ArchitectureMenu_transport_clicked(from_architecture):
	$FromArchitecture.text = from_architecture.get_name()
	
	self.from_architecture = from_architecture
	to_architecture = null
	to_transport_fund = 0
	to_transport_food = 0
	to_transport_troop = 0
	
	update_views()
	show()


func update_views():
	$FromFund.text = str(from_architecture.fund - to_transport_fund) + "(-" + str(to_transport_fund) + ")"
	$FromFood.text = str(from_architecture.food - to_transport_food) + "(-" + str(to_transport_food) + ")"
	$FromTroop.text = str(from_architecture.troop - to_transport_troop) + "(-" + str(to_transport_troop) + ")"
	
	if to_architecture != null:
		$ToArchitecture.text = to_architecture.get_name()
		$ToFund.text = str(to_architecture.fund + to_transport_fund) + "(+" + str(to_transport_fund) + ")"
		$ToFood.text = str(to_architecture.food + to_transport_food) + "(+" + str(to_transport_food) + ")"
		$ToTroop.text = str(to_architecture.troop + to_transport_troop) + "(+" + str(to_transport_troop) + ")"
	else:
		$ToArchitecture.text = ""
		$ToFund.text = ""
		$ToFood.text = ""
		$ToTroop.text = ""

	$ActionButtons/Confirm.disabled = not (to_transport_fund > 0 or to_transport_food > 0 or to_transport_troop > 0)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_RIGHT) and event.pressed:
			if GameConfig.se_enabled:
				$CancelSound.play()
			hide()


func _on_ToArchitecture_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	call_deferred("emit_signal", "select_architecture", from_architecture)
	

func _on_ArchitectureList_architecture_selected(current_action, current_architecture, selected_arch_ids, other = {}):
	if current_action == ArchitectureList.Action.TRANSPORT_RESOURCE_TO:
		to_architecture = current_architecture.scenario.architectures[selected_arch_ids[0]]
		update_views()


func _on_Cancel_pressed():
	if GameConfig.se_enabled:
		$CancelSound.play()
	hide()
	
	
func _on_Confirm_pressed():
	if GameConfig.se_enabled:
		($ConfirmSound as AudioStreamPlayer).play()
	call_deferred("emit_signal", "confirm_transport_resources", from_architecture, to_architecture, to_transport_fund, to_transport_food, to_transport_troop)
	hide()


func _on_TransportFund_text_entered(new_text):
	to_transport_fund = int($TransportFund.text)
	$TransportFund.text = str(to_transport_fund)
	update_views()
	

func _on_TransportFood_text_entered(new_text):
	to_transport_food = int($TransportFood.text)
	$TransportFood.text = str(to_transport_food)
	update_views()


func _on_TransportTroop_text_entered(new_text):
	to_transport_troop = int($TransportTroop.text)
	$TransportTroop.text = str(to_transport_troop)
	update_views()
