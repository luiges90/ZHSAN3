extends Node2D
class_name Troop

var military_kind setget forbidden

func forbidden(x):
	assert(false)
	
func _ready():
	military_kind = 1
	_update_military_kind_sprite()
	$TroopArea/AnimatedSprite.animation = "move_e"
	$TroopArea/AnimatedSprite.play()

func _update_military_kind_sprite():
	var textures = SharedData.troop_images.get(military_kind, null)
	if textures == null:
		var attack = load("res://Images/Troop/" + str(military_kind) + "/Attack.png")
		var be_attacked = load("res://Images/Troop/" + str(military_kind) + "/BeAttacked.png")
		var move = load("res://Images/Troop/" + str(military_kind) + "/Move.png")
		if attack != null and be_attacked != null and move != null:
			textures = {
				"attack": attack,
				"be_attacked": be_attacked,
				"move": move
			}
			SharedData.troop_images[military_kind] = textures
	
	var sprite_frame = SpriteFrames.new()
	
	var directions = ['ne', 'e', 'se', 's', 'sw', 'w', 'nw', 'n']
	for i in range(0, 8):
		_set_frames(sprite_frame, "move_" + directions[i], textures["move"].get_data(), 128 * i)
		_set_frames(sprite_frame, "be_attacked_" + directions[i], textures["be_attacked"].get_data(), 128 * i)
		_set_frames(sprite_frame, "attack_" + directions[i], textures["attack"].get_data(), 128 * i)
		
	var animated_sprite = $TroopArea/AnimatedSprite as AnimatedSprite
	animated_sprite.frames = sprite_frame
	
func _set_frames(sprite_frame, animation, texture, spritesheet_offset):
	sprite_frame.add_animation(animation)
	sprite_frame.set_animation_speed(animation, 30)
	for i in range(0, 10):
		var sprite = Image.new()
		sprite.create(128, 128, false, texture.get_format())
		sprite.blit_rect(texture, Rect2(i * 128, spritesheet_offset, 128, 128), Vector2(0, 0))
		
		var image = ImageTexture.new()
		image.create_from_image(sprite)
		
		sprite_frame.add_frame(animation, image)
