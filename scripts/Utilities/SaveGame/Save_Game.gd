extends Resource

class_name Save_Game

export(Resource) var party
export var cur_map : String = ""
export var cur_access_point : int = -1
export var completed_actions_nodes : Dictionary = {}

class Eq_Info:
	extends Resource
	
	export var legs : String
	export var torso : String
	export var weapon : String
	export var accessory_1 : String
	export var accessory_2 : String
	export var accessory_3 : String
