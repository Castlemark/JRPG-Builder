class_name Utils

static func get_path(path : String) -> String:
	return ProjectSettings.globalize_path(path)

static func _read_img(direction : String) -> Image:
	var path : String = get_path(direction)
	
	var file_exists := File.new().file_exists(path)
	if not file_exists:
		print("Error loading image at -> " + path + " <- Please check that the image exists and the name is correct")
		return null
	
	var img : Image = Image.new()
	var itex : ImageTexture = ImageTexture.new()
	
	img.load(path)
	return img

static func load_img_3D(direction : String) -> Resource:
	var img = _read_img(direction)
	if img == null:
		return null
	var itex : ImageTexture = ImageTexture.new()
	
	itex.create_from_image(img, 16)
	return itex

static func load_img_GUI(direction : String) -> Resource:
	var img = _read_img(direction)
	if img == null:
		return null
	var itex : ImageTexture = ImageTexture.new()
	
	itex.create_from_image(img, 0)
	return itex

static func _read_directory(direction : String) -> Directory:
	var path : String = get_path(direction)
	var files = []
	var dir = Directory.new()
	var open_dir_status : int = dir.open(path)
	if open_dir_status != OK:
		print("Error when opening directory at -> " + path + " <-. Please make sure the directory exists, is in it's expected location and has it's appropriate name, error is: \n	" + String(open_dir_status))
		return null
	
	var begin_list_dir : int = dir.list_dir_begin()
	if begin_list_dir != OK:
		print("Error when reading files at directory -> " + path + " <-. Please make sure the directory isn't empty, is in it's expected location and has it's appropriate name, error is: \n	" + String(begin_list_dir))
		return null
	
	return dir

static func scan_directories_in_directory(direction : String):
	var dir = _read_directory(direction)
	if dir == null:
		return null
	var files := []
	
	# Get every folder in directory
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and (not ".import" in file) and dir.current_is_dir():
			files.append(file)
	
	dir.list_dir_end()
	return files

static func scan_files_in_directory(direction : String):
	var dir = _read_directory(direction)
	if dir == null:
		return null
	var files := []
	
	# Get every file in directory
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and (not ".import" in file) and not dir.current_is_dir():
			files.append(file)
	
	dir.list_dir_end()
	return files

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
