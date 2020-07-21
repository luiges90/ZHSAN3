extends Node

const TILE_SIZE = 50

const TROOP_ANIMATION_SPEED = 30
const TROOP_SPRITE_SIZE = 128
const TROOP_SPRITE_SHEET_FRAMES = 10

var loading_file_path

###########################
#        Resources        #
###########################
const PERSON_PORTRAIT_DEFAULT_MALE_OFFICER = -1
const PERSON_PORTRAIT_DEFAULT_MALE_MARTIAL = -2
const PERSON_PORTRAIT_DEFAULT_FEMALE = -3
const PERSON_PORTRAIT_BLANK = -9999
var person_portraits = {}

var troop_images = {}
var troop_sounds = {}
var troop_sprite_frames = {}

func _init():
	_load_troop_images()
	_load_troop_sounds()
	_load_person_portraits()
	
func _load_troop_images():
	var dir = Directory.new()
	dir.open("res://Images/Troop")
	dir.list_dir_begin()
	while true:
		var in_dir_name = dir.get_next()
		if in_dir_name == "":
			break
		elif not in_dir_name.begins_with(".") and dir.current_is_dir() and int(in_dir_name) > 0:
			var path = "res://Images/Troop/" + in_dir_name
			var attack = load(path + "/Attack.png")
			var be_attacked = load(path + "/BeAttacked.png")
			var move = load(path + "/Move.png")
			if attack != null and be_attacked != null and move != null:
				var textures = {
					"attack": attack,
					"be_attacked": be_attacked,
					"move": move
				}
				troop_images[int(in_dir_name)] = textures
				
func _load_troop_sprite_frames(military_kinds):
	for military_kind in military_kinds:
		var textures = SharedData.troop_images.get(military_kind.id, null)
		if textures != null:
			var sprite_frame = SpriteFrames.new()
			var directions = ['ne', 'e', 'se', 's', 'sw', 'w', 'nw', 'n']
			for i in range(0, 8):
				__set_frames(sprite_frame, "move_" + directions[i], textures["move"].get_data(), TROOP_SPRITE_SIZE * i)
				__set_frames(sprite_frame, "be_attacked_" + directions[i], textures["be_attacked"].get_data(), TROOP_SPRITE_SIZE * i)
				__set_frames(sprite_frame, "attack_" + directions[i], textures["attack"].get_data(), TROOP_SPRITE_SIZE * i)
			troop_sprite_frames[military_kind.id] = sprite_frame
			
func __set_frames(sprite_frame, animation, texture, spritesheet_offset):
	sprite_frame.add_animation(animation)
	sprite_frame.set_animation_speed(animation, TROOP_ANIMATION_SPEED)
	for i in range(0, TROOP_SPRITE_SHEET_FRAMES):
		var sprite = Image.new()
		sprite.create(TROOP_SPRITE_SIZE, TROOP_SPRITE_SIZE, false, texture.get_format())
		sprite.blit_rect(texture, Rect2(i * TROOP_SPRITE_SIZE, spritesheet_offset, TROOP_SPRITE_SIZE, TROOP_SPRITE_SIZE), Vector2(0, 0))
		
		var image = ImageTexture.new()
		image.create_from_image(sprite)
		
		sprite_frame.add_frame(animation, image)

func _load_troop_sounds():
	var dir = Directory.new()
	dir.open("res://Sounds/Troop")
	dir.list_dir_begin()
	while true:
		var in_dir_name = dir.get_next()
		if in_dir_name == "":
			break
		elif not in_dir_name.begins_with(".") and dir.current_is_dir() and int(in_dir_name) > 0:
			var path = "res://Sounds/Troop/" + in_dir_name

			var attack = load(path + "/Attack.wav")
			var moving = load(path + "/Moving.wav")
			if attack != null and moving != null:
				var sounds = {
					"attack": attack,
					"moving": moving
				}
				troop_sounds[int(in_dir_name)] = sounds

func __load_sound_file(file):
	var wav_file = File.new()
	var stream
	wav_file.open(file, File.READ)
	stream = AudioStreamSample.new()
	stream.format = AudioStreamSample.FORMAT_IMA_ADPCM
	stream.data = wav_file.get_buffer(wav_file.get_len())
	stream.stereo = true
	wav_file.close()
	return stream

func _load_person_portraits():
	var dir = Directory.new()
	var path = "res://Images/PersonPortrait"
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var in_file_name = dir.get_next()
		if in_file_name == "":
			break
		elif not in_file_name.begins_with(".") and in_file_name.ends_with('.jpg'):
			if int(in_file_name) > 0:
				var portrait = load(path + "/" + in_file_name)
				person_portraits[int(in_file_name)] = portrait
			elif in_file_name == 'default-male-martial.jpg':
				var portrait = load(path + "/" + in_file_name)
				person_portraits[PERSON_PORTRAIT_DEFAULT_MALE_MARTIAL] = portrait
			elif in_file_name == 'default-male-officer.jpg':
				var portrait = load(path + "/" + in_file_name)
				person_portraits[PERSON_PORTRAIT_DEFAULT_MALE_OFFICER] = portrait
			elif in_file_name == 'default-female.jpg':
				var portrait = load(path + "/" + in_file_name)
				person_portraits[PERSON_PORTRAIT_DEFAULT_FEMALE] = portrait
			elif in_file_name == 'blank.jpg':
				var portrait = load(path + "/" + in_file_name)
				person_portraits[PERSON_PORTRAIT_BLANK] = portrait
