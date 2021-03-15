extends Panel
class_name TransportDialog

signal select_architecture
signal confirm_transport_resources

var from_architecture = null
var to_architecture = null
var to_transport_fund = 0
var to_transport_food = 0
var to_transport_troop = 0
var to_transport_equipments = {}

var military_kind_labels = {}

func _on_ArchitectureMenu_transport_clicked(from_architecture):
	$S/G/FromArchitecture.text = from_architecture.get_name()
	
	self.from_architecture = from_architecture
	to_architecture = null
	to_transport_fund = 0
	to_transport_food = 0
	to_transport_troop = 0
	to_transport_equipments = {}
	
	update_views()
	show()


func update_views():
	$S/G/FromFund.text = str(from_architecture.fund - to_transport_fund) + "(-" + str(to_transport_fund) + ")"
	$S/G/FromFood.text = str(from_architecture.food - to_transport_food) + "(-" + str(to_transport_food) + ")"
	$S/G/FromTroop.text = str(from_architecture.troop - to_transport_troop) + "(-" + str(to_transport_troop) + ")"
	$S/G/TransportFund.text = str(to_transport_fund)
	$S/G/TransportFood.text = str(to_transport_food)
	$S/G/TransportTroop.text = str(to_transport_troop)
	
	if to_architecture != null:
		$S/G/ToArchitecture.text = to_architecture.get_name()
		$S/G/ToFund.text = str(to_architecture.fund + to_transport_fund) + "(+" + str(to_transport_fund) + ")"
		$S/G/ToFood.text = str(to_architecture.food + to_transport_food) + "(+" + str(to_transport_food) + ")"
		$S/G/ToTroop.text = str(to_architecture.troop + to_transport_troop) + "(+" + str(to_transport_troop) + ")"
	else:
		$S/G/ToArchitecture.text = ""
		$S/G/ToFund.text = ""
		$S/G/ToFood.text = ""
		$S/G/ToTroop.text = ""
		
	if military_kind_labels.size() == 0:
		for mk in from_architecture.scenario.military_kinds.values():
			if mk.has_equipments():
				var items = {}
				
				var lbl_title = Label.new()
				lbl_title.text = mk.get_name()
				$S/G.add_child(lbl_title)
				
				var lbl_from = Label.new()
				lbl_from.align = Label.ALIGN_CENTER
				$S/G.add_child(lbl_from)
				items['from'] = lbl_from
				
				var le_amount = LineEdit.new()
				$S/G.add_child(le_amount)
				le_amount.connect("text_entered", self, "_on_equipment_text_entered", [mk], 0)
				items['amount'] = le_amount
				
				var lbl_to = Label.new()
				lbl_to.align = Label.ALIGN_CENTER
				$S/G.add_child(lbl_to)
				items['to'] = lbl_to
			
				military_kind_labels[mk] = items
	
	var has_transporting_equipment = false
	for mk in military_kind_labels:
		if to_architecture != null:
			var to_transfer = Util.dict_try_get(to_transport_equipments, mk, 0)
			military_kind_labels[mk]['from'].text = str(from_architecture.equipments[mk.id] - to_transfer) + "(-" + str(to_transfer) + ")"
			military_kind_labels[mk]['to'].text = str(to_architecture.equipments[mk.id] + to_transfer) + "(+" + str(to_transfer) + ")"
		else:
			military_kind_labels[mk]['from'].text = ''
			military_kind_labels[mk]['to'].text = ''
			
		military_kind_labels[mk]['amount'].text = str(Util.dict_try_get(to_transport_equipments, mk, 0))
		has_transporting_equipment = has_transporting_equipment or int(military_kind_labels[mk]['amount'].text) > 0

	$ActionButtons/Confirm.disabled = not (to_transport_fund > 0 or to_transport_food > 0 or to_transport_troop > 0 or has_transporting_equipment)

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
	call_deferred("emit_signal", "confirm_transport_resources", from_architecture, to_architecture, to_transport_fund, to_transport_food, to_transport_troop, to_transport_equipments)
	hide()


func _on_TransportFund_text_entered(new_text):
	to_transport_fund = int($S/G/TransportFund.text)
	update_views()
	

func _on_TransportFood_text_entered(new_text):
	to_transport_food = int($S/G/TransportFood.text)
	update_views()


func _on_TransportTroop_text_entered(new_text):
	to_transport_troop = int($S/G/TransportTroop.text)
	update_views()


func _on_equipment_text_entered(new_text, military_kind):
	to_transport_equipments[military_kind] = int(new_text)
	update_views()
	
