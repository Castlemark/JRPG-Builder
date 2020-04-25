extends Resource

class_name Save_Game

export(Resource) var party
export var cur_map : String = ""
export var cur_access_point : int = -1
export var completed_actions_nodes : Dictionary = {}

class Party_Info:
	extends Resource
	
	export(Resource) var first_character
	export(Resource) var second_character
	export(Resource) var third_character
	
	export var inventory : Array

class Char_Info:
	extends Resource
	
	export var name : String
	export var cur_health : int
	export var cur_xp : int
	export(Resource) var equipment

class Eq_Info:
	extends Resource
	
	export var legs : String
	export var torso : String
	export var weapon : String
	export var accessory_1 : String
	export var accessory_2 : String
	export var accessory_3 : String
