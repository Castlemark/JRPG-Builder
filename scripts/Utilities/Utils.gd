class_name Utils

static func get_path(path : String) -> String:
	return ProjectSettings.globalize_path(path)

static func load_img(direction : String) -> Resource:
	var path : String = get_path(direction)
	
	var file_exists := File.new().file_exists(path)
	if not file_exists:
		print("Error loading image at -> " + path + " <- Please check that the image exists and the name is correct")
		return null
	
	var img : Image = Image.new()
	var itex : ImageTexture = ImageTexture.new()
	
	img.load(path)
	itex.create_from_image(img, 16)
	
	return itex

static func load_json(path : String):
	var data : Dictionary = {}
	var file : File = File.new()
	
	var status : int = file.open(get_path(path), file.READ)
	if status != OK:
		print("Error when opening file at -> " + path + " <-. Please make sure the file exists, is in it's expected location and has it's appropriate name, error is: \n	" + String(status))
		return null
	
	var json_data : String = file.get_as_text()
	var validation : String = validate_json(json_data)
	if not validation.empty():
		print("File at -> " + path + " <- doesn't have the correct format, error was: \n	line " + validation)
		return null
	
	data = parse_json(json_data) as Dictionary
	file.close()
	
	return data
