class_name Generic_Validators

static func minimal_info_fields_exist(info : Dictionary, fields : Array, msg : String, name_field : String, id : String = "") -> bool:
	var valid := true
	var missing_fields := []
	
	for field in fields:
		var has_field : bool = info.has(field)
		if not has_field:
			missing_fields.append(field)
		
		if valid:
			valid = has_field
	
	if not valid:
		printerr(info.get(name_field, id) + " " + msg + ". The following fields are missing:\n	" + String(missing_fields))
	
	return valid

static func optional_info_field_exists(info : Dictionary, parent_field : String, fields : Array, msg : String, name_field : String,  id : String = "") -> bool:
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
		printerr(info.get(name_field, id) + " " + msg + ". The following fields are missing:\n	" + String(missing_fields))
	
	return valid

static func type_is_valid(type : String, valid_types: Dictionary, data : Dictionary) -> bool:
	var valid:= true
	
	if type in valid_types.keys():
		for field in valid_types.get(type):
			valid = data.has(field)
			
			if not valid:
				printerr("type " + type + " is valid, but it's at least missing the \"" + field + "\" field")
				return false
		
		return true
	
	printerr("type \"" + type + "\" is not a valid type, valid types are: \n	" + String(valid_types.keys()))
	return false
