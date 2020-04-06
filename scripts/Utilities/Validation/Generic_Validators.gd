class_name Generic_Validators

static func minimal_info_fields_exist(info : Dictionary, fields : Array, msg : String, name_field : String, id : String = "") -> bool:
	var valid := true
	var correct_types := true
	var missing_fields := []
	var incorrect_types := []
	
	for field in fields:
		var has_field : bool = info.has(field.keys()[0])
		var field_is_correct_type : bool
		
		if has_field:
			field_is_correct_type = typeof(info.get(field.keys()[0])) == field.values()[0]
			
			if not field_is_correct_type:
				incorrect_types.append(field.keys()[0])
			
			if correct_types:
				correct_types = field_is_correct_type
		else:
			missing_fields.append(field.keys()[0])
		
		if valid:
			valid = has_field
	
	if not valid:
		printerr(info.get(name_field, id) + " " + msg + ". The following fields are missing:\n	" + String(missing_fields))
	
	if not correct_types:
		printerr("\"" + info.get(name_field, id) + "\" " + msg + ". The following fields have the incorrect type:\n	" + String(incorrect_types))
	
	return valid and correct_types

static func optional_info_field_exists(info : Dictionary, parent_field : String, fields : Array, msg : String, name_field : String,  id : String = "") -> bool:
	var parent_valid : bool = info.has(parent_field)
	
	if not parent_valid:
		return false
	
	var valid := true
	var correct_types := true
	var missing_fields := []
	var incorrect_types := []
	
	for field in fields:
		var has_field : bool = info.get(parent_field).has(field.keys()[0])
		var field_is_correct_type : bool
		
		if has_field:
			field_is_correct_type = typeof(info.get(parent_field).get(field.keys()[0])) == field.values()[0]
			
			if not field_is_correct_type:
				incorrect_types.append(field.keys()[0])
			
			if correct_types:
				correct_types = field_is_correct_type
		else:
			missing_fields.append(field.keys()[0])
		
		if valid:
			valid = has_field
	
	if not valid:
		printerr(info.get(name_field, id) + " " + msg + ". The following fields are missing:\n	" + String(missing_fields))
	
	if not correct_types:
		printerr(info.get(name_field, id) + " " + msg + ". The following fields have the incorrect type:\n	" + String(incorrect_types))
	
	return valid and correct_types

static func type_is_valid(type : String, valid_types: Dictionary, data : Dictionary) -> bool:
	var valid:= true
	var correct_type := true
	
	if type in valid_types.keys():
		for field in valid_types.get(type):
			valid = data.has(field.keys()[0])
			
			if valid:
				correct_type = typeof(data.get(field.keys()[0])) == field.values()[0]
				
				if not correct_type:
					printerr("type " + type + " is valid, but it's field " + field.keys()[0] + " has an incorrect type")
					return false
			else:
				printerr("type " + type + " is valid, but it's at least missing the \"" + field.keys()[0] + "\" field")
				return false
		
		return true
	
	printerr("type \"" + type + "\" is not a valid type, valid types are: \n	" + String(valid_types.keys()))
	return false
