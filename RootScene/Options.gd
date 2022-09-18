extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	GameConfig.load_game_config()

	$G/BGM.button_pressed = GameConfig.bgm_enabled
	$G/SE.button_pressed = GameConfig.se_enabled
	$G/TroopAnimation.button_pressed = GameConfig.enable_troop_animations
	$G/TroopAnimationSpeed.text = str(GameConfig.troop_animation_speed)
	$G/DialogShowTime.text = str(GameConfig.dialog_show_time)
	$G/BubbleShowTime.text = str(GameConfig.bubble_show_time)
	$G/RadioButtonDirectSelect.button_pressed = GameConfig.radio_button_direct_select
	$G/AutoSave.button_pressed = GameConfig.auto_save
	$G/AutoSaveInterval.text = str(GameConfig.auto_save_interval)
	$G/EnableInGameEdit.button_pressed = GameConfig.enable_edit


func _on_Cancel_pressed():
	hide()


func _on_Confirm_pressed():
	GameConfig.bgm_enabled = $G/BGM.pressed
	GameConfig.se_enabled = $G/SE.pressed
	GameConfig.enable_troop_animations = $G/TroopAnimation.pressed
	GameConfig.troop_animation_speed = int($G/TroopAnimationSpeed.text)
	GameConfig.dialog_show_time = int($G/DialogShowTime.text)
	GameConfig.bubble_show_time = int($G/BubbleShowTime.text)
	GameConfig.radio_button_direct_select = $G/RadioButtonDirectSelect.pressed
	GameConfig.auto_save = $G/AutoSave.pressed
	GameConfig.auto_save_interval = max(1, int($G/AutoSaveInterval.text))
	GameConfig.enable_edit = $G/EnableInGameEdit.pressed

	GameConfig.save_game_config()
	hide()

