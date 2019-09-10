extends Node

class_name Validators

const check_docu := "please check the documentation to know the necessary fields"
const _action_types := {
	"travel" : ["map_name", "access_point"]
}

static func minimal_info_fields_exist(info : Dictionary, fields : Array, msg : String, name_field : String) -> bool:
	var valid := true
	var missing_fields := []
	
	for field in fields:
		var has_field : bool = info.has(field)
		if not has_field:
			missing_fields.append(field)
		
		if valid:
			valid = has_field
	
	if not valid:
		printerr(info.get(name_field, "") + " " + msg + "\nThe following fields are missing:\n	" + String(missing_fields))
	
	return valid

static func optional_info_field_exists(info : Dictionary, parent_field : String, fields : Array, msg : String, name_field : String) -> bool:
	var parent_valid : bool = info.has(parent_field)
	
	if not parent_valid:
		return false
	
	var valid := true
	var missing_fields := []
	
	for field in fields:
		var has_field : bool = info.get(parent_field).has(field)
		if not has_field:
			missing_fields.append(field)
		
		if valid:
			valid = has_field
	
	if not valid:
		printerr(info.get(name_field, "") + " " + msg + "\nThe following fields are missing:\n	" + String(missing_fields))
	
	return valid

static func action_is_valid(action : String, data : Dictionary) -> bool:
	var valid:= true
	
	if action in _action_types.keys():
		for field in _action_types.get(action):
			valid = data.has(field)
			
			if not valid:
				printerr("action " + action + " has all required fields, but it's data field is missing the " + field + " f ield")
				return false
		
		return true
	
	printerr("action \"" + action + "\" is not a valid action type, valid types are: \n	" + String(_action_types.keys()))
	return false
