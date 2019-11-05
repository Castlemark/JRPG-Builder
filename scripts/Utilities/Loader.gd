class_name Loaders

class Campaign_Loader:
	
	var campaign_data : Model.Campaign_Data
	
	func load_campaign(campaign_name : String) -> Model.Campaign_Data:
		print("■■■■■■■■■■■■■■■■■■■■■■■■■■\nLOADING CAMPAIGN: " + campaign_name + "\n■■■■■■■■■■■■■■■■■■■■■■■■■■")
		
		var load_correct = true
		# TODO Validate campaign file
		var campaign_dict = Utils.load_json("res://campaigns/" + campaign_name + "/campaign.json")
		
		campaign_data = Model.Campaign_Data.new()
		
		var maps : Dictionary = load_all_maps(campaign_name)
		if maps.empty():
			load_correct = false
		elif not maps.has(campaign_dict.map_name):
			load_correct = false
			print("\nStarting map \"" + campaign_dict.map_name + "\" does not exist or has not loaded correctly, please make sure the map exists and is in the correct place")
		campaign_data.maps = maps
		campaign_data.cur_map = campaign_dict.map_name
		
		if not load_correct:
			print("\nCampaign \"" + campaign_name + "\" could not be loaded look above to see what were the errors")
			return null
		
		print("\n ■■■■■■■■■■■■■■■■■■■■■■■■■■\nCampaign loaded successfully!\n ■■■■■■■■■■■■■■■■■■■■■■■■■■")
		return campaign_data
	
	func load_all_maps(campaign_name : String) -> Dictionary:
		print("########################\n##### LOADING MAPS #####\n########################")
		
		var load_correct = true
		var map_names : Array = Utils.scan_directories_in_directory("res://campaigns/" + campaign_name + "/maps")
		
		if map_names == null:
			load_correct = false
			return {}
		
		var maps := {}
		for map_name in map_names:
			var map_data : Model.Map_Data = load_map(map_name, campaign_name)
			if map_data == null:
				print("\n	Map could not be loaded correctly\n------------------------------------")
				load_correct = false
				continue
			
			maps[map_name] = map_data
		
		if not load_correct:
			return {}
		
		return maps
	
	func load_map(map_name : String, campaign_name : String) -> Model.Map_Data:
		print("------------------------------------\nLoading map : " + map_name)
		
		var load_correct := true
		var map_dict : Dictionary = Utils.load_json("res://campaigns/" + campaign_name + "/maps/" + map_name + "/map.json")
		
		if map_dict == null:
			load_correct = false
			return null
		
		if not Validator.map_is_valid(map_dict):
			load_correct = false
			return null
		
		var map_data := Model.Map_Data.new()
		map_data.name = map_name
		
		# Navigation Nodes
		map_data.navigation_nodes = []
		for node_info in map_dict.navigation_nodes:
			var nav_node_data := Model.Map_Data.Nav_Node_Data.new()
			
			# Actions
			nav_node_data.actions = []
			for action_info in node_info.actions:
				if not Generic_Validators.minimal_info_fields_exist(action_info, Data.Validation.type_data, "action has missing or incorrect required fields, " + Data.Validation.check_docu, "type"):
					load_correct = false
					continue
				
				if not Generic_Validators.type_is_valid(action_info.type as String, Data.Validation.action_types, action_info.data):
					load_correct = false
					continue
				
				var action_data := Model.Map_Data.Nav_Node_Data.Action_Data.new()
				action_data.type = action_info.type
				action_data.data = action_info.data
				
				nav_node_data.actions.append(action_data)
			
			nav_node_data.x = node_info.x
			nav_node_data.y = node_info.y
			nav_node_data.connected_nodes = node_info.connected_nodes
			
			map_data.navigation_nodes.append(nav_node_data)
		
		# Details
		map_data.detail_art = []
		for detail_info in map_dict.detail_art:
			if not (detail_info.rotation == 0 or detail_info.rotation == 1):
				print("Detail " + detail_info.filepath + " contains rotation field, but value is not valid, it must be either 0 for horizontal or 1 for vertical")
				load_correct = false
				continue
			
			var detail_data := Model.Map_Data.Detail_Art_Data.new()
			detail_data.x = detail_info.x
			detail_data.y = detail_info.y
			detail_data.rotation = detail_info.rotation as int
			detail_data.filepath = detail_info.filepath
			if Generic_Validators.optional_info_field_exists(detail_info, "animation_data", Data.Validation.animation_data, "detail is marked as animated, but it's requeried animation_data fields are either missing or incorrect, " + Data.Validation.check_docu, "filepath"):
				var animation_data := Model.Animation_Data.new()
				animation_data.hframes = detail_info.animation_data.hframes as int
				animation_data.vframes = detail_info.animation_data.vframes as int
				animation_data.total_frames = detail_info.animation_data.total_frames as int
				animation_data.duration = detail_info.animation_data.duration
				
				detail_data.animation_data = animation_data
			else:
				detail_data.animation_data = null
			
			map_data.detail_art.append(detail_data)
		
		# Background Info
		var background_data := Model.Map_Data.BG_Data.new()
		background_data.x_offset = map_dict.background_info.x_offset
		background_data.y_offset = map_dict.background_info.y_offset
		
		map_data.background_info = background_data
		
		if not load_correct:
			print("------------------------------------")
			return null
		
		print("	Successfully loaded map\n------------------------------------")
		return map_data
	
	func load_all_characters(campaign_name : String) -> Dictionary:
		return {}
	
	func load_character(character_path) ->  Model.Character_Data:
		var character_data := Model.Character_Data.new()
		
		return character_data