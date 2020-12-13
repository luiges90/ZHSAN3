extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	$G/SE.pressed = GameConfig.se_enabled
	$G/TroopAnimation.pressed = GameConfig.enable_troop_animations
	$G/TroopAnimationSpeed.text = str(GameConfig.troop_animation_speed)
	$G/DialogShowTime.text = str(GameConfig.dialog_show_time)
	$G/BubbleShowTime.text = str(GameConfig.bubble_show_time)



func _on_Cancel_pressed():
	hide()


func _on_Confirm_pressed():
	GameConfig.se_enabled = $G/SE.pressed
	GameConfig.enable_troop_animations = $G/TroopAnimation.pressed
	GameConfig.troop_animation_speed = int($G/TroopAnimationSpeed.text)
	GameConfig.dialog_show_time = int($G/DialogShowTime.text)
	GameConfig.bubble_show_time = int($G/BubbleShowTime.text)
	GameConfig.auto_save = $G/AutoSave.pressed
	GameConfig.auto_save_interval = int($G/AutoSaveInterval.text)
	hide()
