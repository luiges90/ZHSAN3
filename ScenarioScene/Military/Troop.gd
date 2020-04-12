extends Node2D
class_name Troop

const SPRITE_SIZE = 128
const SPRITE_SHEET_FRAMES = 10
const ANIMATION_SPEED = 30

var id: int setget forbidden
var scenario

var map_position: Vector2 setget forbidden

var military_kind setget forbidden
var quantity: int setget forbidden
var morale: int setget forbidden
var combativity: int setget forbidden

var _person_list = Array() setget forbidden, get_persons

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
		_set_frames(sprite_frame, "move_" + directions[i], textures["move"].get_data(), SPRITE_SIZE * i)
		_set_frames(sprite_frame, "be_attacked_" + directions[i], textures["be_attacked"].get_data(), SPRITE_SIZE * i)
		_set_frames(sprite_frame, "attack_" + directions[i], textures["attack"].get_data(), SPRITE_SIZE * i)
		
	var animated_sprite = $TroopArea/AnimatedSprite as AnimatedSprite
	animated_sprite.frames = sprite_frame
	
func _set_frames(sprite_frame, animation, texture, spritesheet_offset):
	sprite_frame.add_animation(animation)
	sprite_frame.set_animation_speed(animation, ANIMATION_SPEED)
	for i in range(0, SPRITE_SHEET_FRAMES):
		var sprite = Image.new()
		sprite.create(SPRITE_SIZE, SPRITE_SIZE, true, texture.get_format())
		sprite.blit_rect(texture, Rect2(i * SPRITE_SIZE, spritesheet_offset, SPRITE_SIZE, SPRITE_SIZE), Vector2(0, 0))
		
		var image = ImageTexture.new()
		image.create_from_image(sprite)
		
		sprite_frame.add_frame(animation, image)

func load_data(json: Dictionary):
	id = json["_Id"]
	
	map_position = Util.load_position(json["MapPosition"])
	
	military_kind = scenario.military_kinds[json["MilitaryKind"]]
	quantity = json["Quantity"]
	morale = json["Morale"]
	combativity = json["Combativity"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"MapPosition": Util.save_position(map_position),
		"PersonList": Util.id_list(get_persons()),
		"MilitaryKind": military_kind.id,
		"Quantity": quantity,
		"Morale": morale,
		"Combativity": combativity
	}

func get_name() -> String:
	return _person_list[0].get_name() + tr('PERSON_TROOP')

func get_persons() -> Array:
	return _person_list
	
func set_persons(list: Array):
	_person_list = list

func set_military_kind(kind):
	military_kind = kind

func set_from_arch(in_quantity, in_morale, in_combativity):
	quantity = in_quantity
	morale = in_morale
	combativity = in_combativity
