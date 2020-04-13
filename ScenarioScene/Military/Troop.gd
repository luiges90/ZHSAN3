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
	_update_military_kind_sprite()
	$TroopArea/AnimatedSprite.animation = "move_e"
	$TroopArea/AnimatedSprite.play()
	
	if scenario:
		position.x = map_position.x * scenario.tile_size
		position.y = map_position.y * scenario.tile_size
		scale.x = 50.0 / 128
		scale.y = 50.0 / 128


func _update_military_kind_sprite():
	var textures = SharedData.troop_images.get(military_kind.id, null)
	var animated_sprite = $TroopArea/AnimatedSprite as AnimatedSprite
	if animated_sprite != null:
		if textures == null:
			var attack = load("res://Images/Troop/" + str(military_kind.id) + "/Attack.png")
			var be_attacked = load("res://Images/Troop/" + str(military_kind.id) + "/BeAttacked.png")
			var move = load("res://Images/Troop/" + str(military_kind.id) + "/Move.png")
			if attack != null and be_attacked != null and move != null:
				textures = {
					"attack": attack,
					"be_attacked": be_attacked,
					"move": move
				}
				SharedData.troop_images[military_kind.id] = textures
		
		var sprite_frame = SpriteFrames.new()
		
		var directions = ['ne', 'e', 'se', 's', 'sw', 'w', 'nw', 'n']
		for i in range(0, 8):
			_set_frames(sprite_frame, "move_" + directions[i], textures["move"].get_data(), SPRITE_SIZE * i)
			_set_frames(sprite_frame, "be_attacked_" + directions[i], textures["be_attacked"].get_data(), SPRITE_SIZE * i)
			_set_frames(sprite_frame, "attack_" + directions[i], textures["attack"].get_data(), SPRITE_SIZE * i)
			
		animated_sprite.frames = sprite_frame
	
func _set_frames(sprite_frame, animation, texture, spritesheet_offset):
	sprite_frame.add_animation(animation)
	sprite_frame.set_animation_speed(animation, ANIMATION_SPEED)
	for i in range(0, SPRITE_SHEET_FRAMES):
		var sprite = Image.new()
		sprite.create(SPRITE_SIZE, SPRITE_SIZE, false, texture.get_format())
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
	
func get_leader():
	return _person_list[0]
	
func set_persons(list: Array):
	_person_list = list

func set_military_kind(kind):
	military_kind = kind
	_update_military_kind_sprite()

func set_from_arch(in_quantity, in_morale, in_combativity):
	quantity = in_quantity
	morale = in_morale
	combativity = in_combativity
	
func set_map_position(pos):
	map_position = pos
	
func get_strength():
	var strength = get_leader().strength
	var max_strength = 0
	for p in get_persons():
		if p.strength > max_strength:
			max_strength = p.strength
	strength = max(strength, max_strength * 0.7)
	return strength
	
func get_command():
	var command = get_leader().command
	var max_command = 0
	for p in get_persons():
		if p.command > max_command:
			max_command = p.command
	command = max(command, max_command * 0.7)
	return command

func get_offence():
	var troop_base = military_kind.base_offence
	var troop_quantity = military_kind.offence * quantity / military_kind.max_quantity_multiplier
	
	return int((troop_base + troop_quantity) * (((get_strength() * 0.3 + get_command() * 0.7) + 10) / 100.0))
	
func get_defence():
	var troop_base = military_kind.base_defence
	var troop_quantity = military_kind.defence * quantity / military_kind.max_quantity_multiplier
	
	return int((troop_base + troop_quantity) * ((get_command() + 10) / 100.0))

func get_speed():
	return military_kind.speed
	
func get_initiative():
	return military_kind.initiative
