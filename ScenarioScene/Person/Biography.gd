extends Node
class_name Biography

var id: int setget forbidden
var scenario

var text: String setget forbidden

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
