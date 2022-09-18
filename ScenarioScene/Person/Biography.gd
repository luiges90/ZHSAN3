extends Node
class_name Biography

var id: int :
	get:
		return id # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var scenario

var text: String :
	get:
		return text # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

func forbidden(x):
	assert(false)
	
####################################
#           Save / Load            #
####################################

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	text = json["Text"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Text": text
	}
