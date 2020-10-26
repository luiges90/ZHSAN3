extends Node
class_name BaseStunt

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var description: String setget forbidden

var influences setget forbidden
var conditions setget forbidden

var combativity_cost: int setget forbidden

func forbidden(x):
	assert(false)