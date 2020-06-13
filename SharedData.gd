extends Node

const TILE_SIZE = 50

var loading_file_path

###########################
#        Resources        #
###########################
var troop_images = {}
var troop_sounds = {}

func _init():
	_load_troop_images()
	_load_troop_sounds()
	
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
