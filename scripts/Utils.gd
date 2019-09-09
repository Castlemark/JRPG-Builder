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
		print("Error when opening json file, error is: " + String(status))
		return
	
	data = parse_json(file.get_as_text()) as Dictionary
	file.close()
	
	return data