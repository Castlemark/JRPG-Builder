class_name Loaders

class Campaign_Loader:

	const _LEVEL = "Level "
	const _MAX_LEVEL = 30

	var campaign_data : Model.Campaign_Data

	func load_campaign(campaign_name : String) -> Model.Campaign_Data:
		print("  ■■■■■■■■■■■■■■■■■■■■■■■■■■\nLOADING CAMPAIGN: " + campaign_name + "\n  ■■■■■■■■■■■■■■■■■■■■■■■■■■\n")

		var load_correct = true
		# TODO Validate campaign file
		var campaign_dict = Utils.load_json("res://campaigns/" + campaign_name + "/campaign.json")

		campaign_data = Model.Campaign_Data.new()
		campaign_data.name = campaign_name

		# ABILITIES
		var abilities : Dictionary = load_all_abilities(campaign_name)
		if abilities.empty():
			load_correct = false
		campaign_data.abilities = abilities

		# ITMES
		var items : Dictionary = load_all_items(campaign_name)
		if items.empty():
			load_correct = false
		campaign_data.items = items

		# ENEMIES
		var enemies : Dictionary = load_all_enemies(campaign_name)
		if enemies.empty():
			load_correct = false
		campaign_data.enemies = enemies

		# CHARACTERS
		var characters : Dictionary = load_all_characters(campaign_name)
		if characters.empty():
			load_correct = false
		campaign_data.characters = characters

		# PARTY
		var i = 0
		var party := Model.Party_Data.new()
		for character in campaign_dict.party:
			if not characters.has(character):
				load_correct = false
				print("\nYour party has the character \"" + character + "\", but this character does not exist or has not loaded correctly, please make sure the character exists and is in the correct place")
			else:
				if i==0:
					party.first_character = campaign_data.characters.get(character)
				elif i==1:
					party.second_character = campaign_data.characters.get(character)
				elif i==2:
					party.third_character = campaign_data.characters.get(character)

				i += 1

		#INVENTORY
		for inventory_item in campaign_dict.inventory:
			if not campaign_data.items.has(inventory_item):
				load_correct = false
				print("\nYour inventory has the item\"" + inventory_item  + "\", but this item does not exist or has not loaded correctly, please make sure the character exists and is in the correct place")
			else:
				party.inventory.append(campaign_data.items.get(inventory_item))

		party.money = 0
		campaign_data.party = party

		# MAPS
		var maps : Dictionary = load_all_maps(campaign_name)
		if maps.empty():
			load_correct = false
		elif not maps.has(campaign_dict.map_name):
			load_correct = false
			print("\nStarting map \"" + campaign_dict.map_name + "\" does not exist or has not loaded correctly, please make sure the map exists and is in the correct place")
		campaign_data.maps = maps
		campaign_data.cur_map = campaign_dict.map_name

		# DIALOGUES
		# TODO load portraits
		var portraits := load_all_portraits(campaign_name)
		if portraits.empty():
			load_correct = false
		campaign_data.portraits = portraits
		
		var dialogues := load_all_dialogues(campaign_name)
		if dialogues.empty():
			load_correct = false
		campaign_data.dialogues = dialogues

		# FINAL STEPS
		if not load_correct:
			print("\nCampaign \"" + campaign_name + "\" could not be loaded, look above to see what were the errors")
			return null

		print(" ■■■■■■■■■■■■■■■■■■■■■■■■■■\nCAMPAIGN LOADED SUCESSFULLY!\n ■■■■■■■■■■■■■■■■■■■■■■■■■■")
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

		print("ALL MAPS LOADED SUCCSSFULLY!\n")
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

				if action_info.type == "combat":
					if action_info.data.enemies.size() < 1 || action_info.data.enemies.size() > 3:
						load_correct = false
						print("Action combat has " + action_info.data.enemies.size() as String + " enemies, but can only have between 1 and 3 enemies")

					for enemy in action_info.data.enemies:
						if not campaign_data.enemies.has(enemy):
							load_correct = false
							print("Action combat has the necessary fields, but enenmy \"" + enemy + "\" could not be loaded or does not exist")
				
				elif action_info.type == "treasure":
					if action_info.data.money < 0:
						load_correct = false
						print("Action treasure has " + String(action_info.data.money) +  " money, but the value must be positive")
					
					for item in action_info.data.items:
						if not campaign_data.items.has(item):
							load_correct = false
							print("Action treasure has the necessary fields, but item \"" + item + "\" could not be loaded or does not exist")
				
				elif action_info.type == "travel":
					pass # TODO check destination exists as map.json and  target node is positive

				if not load_correct:
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
		var detail_cache := {}
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

			if detail_info.scale <= 0:
				load_correct = false
				print("detail " + detail_data.filepath + " in map has \"scale\" field but is an invalid value, please make sure the scale is bigger than 0")
				detail_data.scale = 1
			else:
				detail_data.scale = detail_info.scale

			if Generic_Validators.optional_info_field_exists(detail_info, "animation_data", Data.Validation.animation_data, "detail is marked as animated, but it's requeried animation_data fields are either missing or incorrect, " + Data.Validation.check_docu, "filepath"):
				var animation_data := Model.Animation_Data.new()
				animation_data.hframes = detail_info.animation_data.hframes as int
				animation_data.vframes = detail_info.animation_data.vframes as int
				animation_data.total_frames = detail_info.animation_data.total_frames as int
				animation_data.duration = detail_info.animation_data.duration

				detail_data.animation_data = animation_data
			else:
				detail_data.animation_data = null

			if not detail_cache.has(detail_info.filepath):
				detail_data.texture = Utils.load_img_3D("res://campaigns/" + campaign_name + "/maps/" + map_name + "/detail_art/" + detail_info.filepath + ".png")
				if detail_data.texture == null:
					print("	detail" + detail_info.filepath + " texture could not be Loaded, please make sure the texture exists and has the correct name")
					load_correct = false
				else:
					detail_cache[detail_info.filepath] = detail_data.texture
			else:
				detail_data.texture = detail_cache[detail_info.filepath]

			map_data.detail_art.append(detail_data)

		# Background Info
		var background_data := Model.Map_Data.BG_Data.new()
		background_data.x_offset = map_dict.background_info.x_offset
		background_data.y_offset = map_dict.background_info.y_offset
		if map_dict.background_info.scale <= 0:
			load_correct = false
			print("\"background_info\" field in map has \"scale\" field but is an invalid value, please make sure the scale is bigger than 0")
			background_data.scale = 1
		else:
			background_data.scale = map_dict.background_info.scale

		map_data.background_info = background_data

		#Textures
		map_data.combat_background = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/maps/" + map_name +  "/combat_background.png")
		if map_data.combat_background == null:
			print("	combat background could not be Loaded, please make sure the image exists and has the correct name")
			load_correct = false

		map_data.map_floor = Utils.load_img_3D("res://campaigns/" + campaign_name + "/maps/" + map_name + "/map.png")
		if map_data.map_floor == null:
			print("	map floor texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		map_data.intersection_texture = Utils.load_img_3D("res://campaigns/" + campaign_name + "/maps/" + map_name + "/map_nodes/node_intersection.png")
		if map_data.intersection_texture == null:
			print("	intersection node texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		map_data.path_texture = Utils.load_img_3D("res://campaigns/" + campaign_name + "/maps/" + map_name + "/map_nodes/node_path.png")
		if map_data.path_texture == null:
			print("	path node texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		map_data.between_texture = Utils.load_img_3D("res://campaigns/" + campaign_name + "/maps/" + map_name + "/map_nodes/node_between.png")
		if map_data.between_texture == null:
			print("	path node texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		map_data.avatar_texture = Utils.load_img_3D("res://campaigns/" + campaign_name + "/maps/" + map_name + "/player_avatar.png")
		if map_data.map_floor == null:
			print("	map floor texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		if not load_correct:
			return null

		print("	Successfully loaded map\n------------------------------------")
		return map_data

	func load_all_characters(campaign_name : String) -> Dictionary:
		print("##############################\n##### LOADING CHARACTERS #####\n##############################")

		var load_correct = true
		var character_names : Array = Utils.scan_directories_in_directory("res://campaigns/" + campaign_name + "/characters/party")

		if character_names == null:
			load_correct = false
			return {}

		var characters := {}
		for character_name in character_names:
			var character_data : Model.Character_Data = load_character(character_name, campaign_name)
			if character_data == null:
				print("\n	Character could not be loaded correctly\n------------------------------------")
				load_correct = false
				continue

			characters[character_name] = character_data

		if not load_correct:
			return {}

		print("ALL CHARACTERS LOADED SUCCESSFULLY!\n")
		return characters

	func load_character(character_name : String, campaign_name : String) ->  Model.Character_Data:
		print("------------------------------------\nLoading character : " + character_name)

		var load_correct := true
		var character_dict : Dictionary = Utils.load_json("res://campaigns/" + campaign_name + "/characters/party/" + character_name + "/character.json")

		if character_dict == null:
			load_correct = false
			return null

		if not Validator.character_is_valid(character_dict, character_name):
			load_correct = false
			return null

		var character_data := Model.Character_Data.new()
		character_data.name = character_name

		# Level
		character_data.start_xp = character_dict.start_xp as int
		character_data.cur_xp = character_data.start_xp as int

		# Scale
		if character_dict.scale <= 0:
			load_correct = false
			print("Character has \"scale\" field but is an invalid value, please make sure the scale is bigger than 0")
			character_data.scale = 1
		else:
			character_data.scale = character_dict.scale

		# Min Stats
		var min_stats := Model.Stats_Data.new()
		min_stats.critic = character_dict.min_stats.critic
		min_stats.speed = character_dict.min_stats.speed as int
		min_stats.health = character_dict.min_stats.health as int
		min_stats.max_health = min_stats.health
		min_stats.strain = character_dict.min_stats.strain as int
		min_stats.max_strain = min_stats.strain
		min_stats.evasion = character_dict.min_stats.evasion
		min_stats.max_evasion = min_stats.evasion
		min_stats.damage = character_dict.min_stats.damage as int
		min_stats.max_damage = min_stats.damage

		character_data.min_stats = min_stats

		# Max Stats
		var max_stats := Model.Stats_Data.new()
		max_stats.critic = character_dict.max_stats.critic
		max_stats.speed = character_dict.max_stats.speed as int
		max_stats.health = character_dict.max_stats.health as int
		max_stats.max_health = max_stats.health
		max_stats.strain = character_dict.max_stats.strain as int
		max_stats.max_strain = max_stats.strain
		max_stats.evasion = character_dict.max_stats.evasion
		max_stats.max_evasion = max_stats.evasion
		max_stats.damage = character_dict.max_stats.damage as int
		max_stats.max_damage = max_stats.damage

		character_data.max_stats = max_stats

		# Cur Stats
		var stats := Model.Stats_Data.new()

		stats.critic = min_stats.critic + (character_data.cur_level() - 1) * float(max_stats.critic - min_stats.critic)/_MAX_LEVEL
		stats.speed = min_stats.speed + (character_data.cur_level() - 1) * float(max_stats.speed - min_stats.speed)/_MAX_LEVEL
		stats.health = min_stats.health + ((character_data.cur_level() - 1) * float(max_stats.health - min_stats.health)/_MAX_LEVEL)
		stats.max_health = stats.health
		stats.strain = min_stats.strain + ((character_data.cur_level() - 1) * float(max_stats.strain - min_stats.strain)/_MAX_LEVEL)
		stats.max_strain = stats.strain
		stats.evasion = min_stats.evasion + ((character_data.cur_level() - 1) * float(max_stats.evasion - min_stats.evasion)/_MAX_LEVEL)
		stats.max_evasion = stats.evasion
		stats.damage = min_stats.damage + ((character_data.cur_level() - 1) * float(max_stats.damage - min_stats.damage)/_MAX_LEVEL)
		stats.max_damage = stats.damage

		character_data.stats = stats

		# Equipment
		var equipment := Model.Character_Data.Equipment_Data.new()
		if not campaign_data.items.has(character_dict.equipment.legs):
			print(character_data.name + "character is valid, but the \"" + character_dict.equipment.legs + "\" item on it's " + "legs" + " slot is invalid or may not exist, please check the messages above to see what equipments")
			load_correct = false
		else:
			equipment.legs = campaign_data.items.get(character_dict.equipment.legs)

		if not campaign_data.items.has(character_dict.equipment.torso):
			print(character_data.name + "character is valid, but the \"" + character_dict.equipment.torso + "\" item on it's " + "torso" + " slot is invalid or may not exist, please check the messages above to see what equipments")
			load_correct = false
		else:
			equipment.torso = campaign_data.items.get(character_dict.equipment.torso)

		if not campaign_data.items.has(character_dict.equipment.accessory_1):
			print(character_data.name + "character is valid, but the \"" + character_dict.equipment.accessory_1 + "\" item on it's " + "accessory_1" + " slot is invalid or may not exist, please check the messages above to see what equipments")
			load_correct = false
		else:
			equipment.accessory_1 = campaign_data.items.get(character_dict.equipment.accessory_1)

		if not campaign_data.items.has(character_dict.equipment.accessory_2):
			print(character_data.name + "character is valid, but the \"" + character_dict.equipment.accessory_2 + "\" item on it's " + "accessory_2" + " slot is invalid or may not exist, please check the messages above to see what equipments")
			load_correct = false
		else:
			equipment.accessory_2 = campaign_data.items.get(character_dict.equipment.accessory_2)

		if not campaign_data.items.has(character_dict.equipment.accessory_3):
			print(character_data.name + "character is valid, but the \"" + character_dict.equipment.accessory_3 + "\" item on it's " + "accessory_3" + " slot is invalid or may not exist, please check the messages above to see what equipments")
			load_correct = false
		else:
			equipment.accessory_3 = campaign_data.items.get(character_dict.equipment.accessory_3)

		if not campaign_data.items.has(character_dict.equipment.weapon):
			print(character_data.name + "character is valid, but the \"" + character_dict.equipment.weapon + "\" item on it's " + "weapon" + " slot is invalid or may not exist, please check the messages above to see what equipments")
			load_correct = false
		else:
			equipment.weapon = campaign_data.items.get(character_dict.equipment.weapon)

		character_data.equipment = equipment

		# Animation Data
		if Generic_Validators.optional_info_field_exists(character_dict, "animation_data", Data.Validation.animation_data, "character is marked as animated, but it's requeried animation_data fields are either missing or incorrect, " + Data.Validation.check_docu, "filepath"):
			var animation_data := Model.Animation_Data.new()
			animation_data.hframes = character_dict.animation_data.hframes as int
			animation_data.vframes = character_dict.animation_data.vframes as int
			animation_data.total_frames = character_dict.animation_data.total_frames as int
			animation_data.duration = character_dict.animation_data.duration

			character_data.animation_data = animation_data
		else:
			character_data.animation_data = null

		# Abilities
		character_data.abilities = {}
		for ability_name in character_dict.abilities:
			if not campaign_data.abilities.has(ability_name):
				print("the ability \"" + ability_name + "\" does not exist or has not loaded correctly, please make sure the ability exists and is in the correct place")
				load_correct = false
				continue

			character_data.abilities[ability_name] = campaign_data.abilities.get(ability_name)

		#Textures
		character_data.icon_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/party/" + character_name + "/icon.png")
		if character_data.icon_texture == null:
			print("	party character icon could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		character_data.attack_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/party/" + character_name + "/attack.png")
		if character_data.attack_texture == null:
			print("	party character attack texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		character_data.hit_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/party/" + character_name + "/hit.png")
		if character_data.hit_texture == null:
			print("	party character hit texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		character_data.idle_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/party/" + character_name + "/idle.png")
		if character_data.idle_texture == null:
			print("	party character idle texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		character_data.miss_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/party/" + character_name + "/miss.png")
		if character_data.attack_texture == null:
			print("	party character miss texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		if not load_correct:
			return null

		print("	Successfully loaded character\n------------------------------------")
		return character_data

	func load_all_abilities(campaign_name : String) -> Dictionary:
		print("#############################\n##### LOADING ABILITIES #####\n#############################")

		var load_correct = true
		var ability_names : Array = Utils.scan_directories_in_directory("res://campaigns/" + campaign_name + "/abilities")

		if ability_names == null:
			load_correct = false
			return {}

		var abilities := {}
		for ability_name in ability_names:
			var ability_data : Model.Ability_Data = load_ability(ability_name, campaign_name)
			if ability_data == null:
				print("\n	Ability could not be loaded correctly\n------------------------------------")
				load_correct = false
				continue

			abilities[ability_name] = ability_data

		if not load_correct:
			return {}

		print("ALL ABILITIES LOADED SUCESSFULLY!\n")
		return abilities

	func load_ability(ability_name : String, campaign_name : String) -> Model.Ability_Data:
		print("------------------------------------\nLoading ability : " + ability_name)

		var load_correct := true
		var ability_dict : Dictionary = Utils.load_json("res://campaigns/" + campaign_name + "/abilities/" + ability_name + "/ability.json")

		if ability_dict == null:
			load_correct = false
			return null

		if not Validator.ability_is_valid(ability_dict, ability_name):
			load_correct = false
			return null

		var ability_data := Model.Ability_Data.new()
		ability_data.name = ability_name

		# Direct Stats
		ability_data.min_level = ability_dict.min_level as int
		ability_data.side = ability_dict.side
		ability_data.cost = ability_dict.cost as int
		ability_data.type = ability_dict.type
		ability_data.amount = ability_dict.amount
		ability_data.description = ability_dict.description

		#Textures
		ability_data.icon_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/abilities/" + ability_name + "/icon.png")
		if ability_data.icon_texture == null:
			print("	ability icon could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		if not load_correct:
			return null

		print("	Successfully loaded ability\n------------------------------------")
		return ability_data

	func load_all_items(campaign_name : String) -> Dictionary:
		print("#########################\n##### LOADING ITEMS #####\n#########################")

		var load_correct = true
		var item_names : Array = Utils.scan_directories_in_directory("res://campaigns/" + campaign_name + "/items")

		if item_names == null:
			load_correct = false
			return {}

		var items := {}
		for item_name in item_names:
			print("------------------------------------\nLoading item : " + item_name)
			var item_dict : Dictionary = Utils.load_json("res://campaigns/" + campaign_name + "/items/" + item_name +"/item.json")

			if item_dict == null:
				load_correct = false
				print("	\nItem could not be loaded correctly\n------------------------------------")
				continue
			if not Validator.item_is_valid(item_dict, item_name):
				load_correct = false
				print("	\nItem could not be loaded correctly\n------------------------------------")
				continue

			#Textures
			var icon_item : Texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/items/" + item_name + "/item.png")
			if icon_item == null:
				print("	item icon could not be Loaded, please make sure the icon exists and has the correct name")
				load_correct = false
				continue

			var item_data
			match item_dict.type:
				"equipment":
					item_data = load_equipment(item_name, item_dict.data, icon_item)
				"quest_object":
					item_data = load_quest_item(item_name, item_dict.data, icon_item)
				"consumable":
					item_data = load_consumable(item_name, item_dict.data, icon_item)

			print("	Successfully loaded item\n------------------------------------")
			items[item_name] = item_data

		if not load_correct:
			return {}

		print("ALL ITEMS LOADED SUCESSFULLY!\n")
		return items

	func load_consumable(item_name : String, item_dict : Dictionary, icon_texture : Texture) -> Model.Item_Data.Consumable_Data:
		var item_data := Model.Item_Data.Consumable_Data.new()
		item_data.type = "consumable"

		item_data.name = item_name
		item_data.price = item_dict.price as int

		var item_effect := Model.Item_Data.Consumable_Data.Item_Effect_Data.new()
		item_effect.type = item_dict.effect.type
		item_effect.value = item_dict.effect.delay as int
		item_effect.delay = item_dict.effect.delay as int
		item_effect.duration = item_dict.effect.duration as int

		item_data.effect = item_effect

		item_data.icon_texture = icon_texture

		return item_data

	func load_equipment(item_name : String, item_dict : Dictionary, icon_texture : Texture) -> Model.Item_Data.Equipment_Item_Data:
		var item_data := Model.Item_Data.Equipment_Item_Data.new()
		item_data.type = "equipment"

		item_data.name = item_name
		item_data.price = item_dict.price as int
		item_data.slot = item_dict.slot
		item_data.min_level = item_dict.min_level as int
		item_data.rarity = item_dict.rarity as int

		var item_stats := Model.Stats_Data.new()
		item_stats.critic = item_dict.stats.critic
		item_stats.speed = item_dict.stats.speed as int
		item_stats.health = item_dict.stats.health as int
		item_stats.max_health = item_stats.health
		item_stats.strain = item_dict.stats.strain as int
		item_stats.max_strain = item_stats.strain
		item_stats.evasion = item_dict.stats.evasion
		item_stats.max_evasion = item_stats.evasion
		item_stats.damage = item_dict.stats.damage as int
		item_stats.max_damage = item_stats.max_damage

		item_data.stats = item_stats

		item_data.icon_texture = icon_texture

		return item_data

	func load_quest_item(item_name : String, item_dict : Dictionary, icon_texture : Texture) -> Model.Item_Data.Quest_Object_Data:
		var item_data := Model.Item_Data.Quest_Object_Data.new()

		item_data.name = item_name
		item_data.type = "quest_object"
		item_data.keyword = item_dict.keyword

		item_data.icon_texture = icon_texture

		return item_data

	func load_all_enemies(campaign_name : String) -> Dictionary:
		print("#############################\n###### LOADING ENEMIES ######\n#############################")

		var load_correct = true
		var enemy_names : Array = Utils.scan_directories_in_directory("res://campaigns/" + campaign_name + "/characters/enemies")

		if enemy_names == null:
			load_correct = false
			return {}

		var enemies := {}
		for enemy_name in enemy_names:
			var enemy_data : Model.Enemy_Data = load_enemy(enemy_name, campaign_name)
			if enemy_data == null:
				print("\n	Enemy could not be loaded correctly\n------------------------------------")
				load_correct = false
				continue

			enemies[enemy_name] = enemy_data

		if not load_correct:
			return {}

		print("ALL ENEMIES LOADED SUCESSFULLY!\n")
		return enemies

	func load_enemy(enemy_name : String, campaign_name : String) -> Model.Enemy_Data:
		print("------------------------------------\nLoading enemy : " + enemy_name)

		var load_correct := true
		var enemy_dict = Utils.load_json("res://campaigns/" + campaign_name + "/characters/enemies/" + enemy_name +"/enemy.json")

		if enemy_dict == null:
			load_correct = false
			return null

		if not Validator.enemy_is_valid(enemy_dict, enemy_name):
			load_correct = false
			return null

		var enemy_data := Model.Enemy_Data.new()
		enemy_data.name = enemy_name

		# Scale
		if enemy_dict.scale <= 0:
			load_correct = false
			print("Enemy has \"scale\" field but is an invalid value, please make sure the scale is bigger than 0")
			enemy_data.scale = 1
		else:
			enemy_data.scale = enemy_dict.scale

		if enemy_dict.xp_reward < 0:
			load_correct = false
			print("Enemy has \"xp_reward\" field but is an invalid value, please make sure the xp_reward is bigger or equal than 0")
		else:
			enemy_data.xp_reward = enemy_dict.xp_reward

		# Stats
		var stats := Model.Stats_Data.new()
		stats.critic = enemy_dict.stats.critic
		stats.speed = enemy_dict.stats.speed as int
		stats.health = enemy_dict.stats.health as int
		stats.max_health = stats.health
		stats.strain = enemy_dict.stats.strain as int
		stats.max_strain = stats.strain
		stats.evasion = enemy_dict.stats.evasion
		stats.max_evasion = stats.evasion
		stats.damage = enemy_dict.stats.damage as int
		stats.max_damage = stats.damage

		enemy_data.stats = stats

		# Abilities
		enemy_data.abilities = {}
		for ability_name in enemy_dict.abilities:
			if not campaign_data.abilities.has(ability_name):
				print("the ability \"" + ability_name + "\" does not exist or has not loaded correctly, please make sure the ability exists and is in the correct place")
				load_correct = false
				continue

			enemy_data.abilities[ability_name] = campaign_data.abilities.get(ability_name)

		# Animation Data
		if Generic_Validators.optional_info_field_exists(enemy_dict, "animation_data", Data.Validation.animation_data, "character is marked as animated, but it's requeried animation_data fields are either missing or incorrect, " + Data.Validation.check_docu, "filepath"):
			var animation_data := Model.Animation_Data.new()
			animation_data.hframes = enemy_dict.animation_data.hframes as int
			animation_data.vframes = enemy_dict.animation_data.vframes as int
			animation_data.total_frames = enemy_dict.animation_data.total_frames as int
			animation_data.duration = enemy_dict.animation_data.duration

			enemy_data.animation_data = animation_data
		else:
			enemy_data.animation_data = null

		#Textures
		enemy_data.icon_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/enemies/" + enemy_name + "/icon.png")
		if enemy_data.icon_texture == null:
			print("	enemy icon could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		enemy_data.attack_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/enemies/" + enemy_name + "/attack.png")
		if enemy_data.attack_texture == null:
			print("	enemy attack texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		enemy_data.hit_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/enemies/" + enemy_name + "/hit.png")
		if enemy_data.hit_texture == null:
			print("	enemy hit texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		enemy_data.idle_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/enemies/" + enemy_name + "/idle.png")
		if enemy_data.idle_texture == null:
			print("	enemy idle texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		enemy_data.miss_texture = Utils.load_img_GUI("res://campaigns/" + campaign_name + "/characters/enemies/" + enemy_name + "/miss.png")
		if enemy_data.attack_texture == null:
			print("	enemy miss texture could not be Loaded, please make sure the icon exists and has the correct name")
			load_correct = false

		if not load_correct:
			return null

		print("	Successfully loaded enemy\n------------------------------------")
		return enemy_data

	func load_all_portraits(campaign_name : String) -> Dictionary:
		print("#############################\n##### LOADING PORTRAITS #####\n#############################")
		
		var load_correct = true
		var portrait_files : Array = Utils.scan_files_in_directory("res://campaigns/" + campaign_name + "/dialogues/portraits")
		
		if portrait_files == null:
			load_correct = false
			return {}
		
		var portraits := {}
		for portrait_name in portrait_files:
			print("------------------------------------\nLoading portrait : " + portrait_name)
			var portrait := Utils.load_img_GUI("res://campaigns/" + campaign_name + "/dialogues/portraits/" + portrait_name)
			if portrait == null:
				print("\n	Portrait could not be loaded correctly\n------------------------------------")
				load_correct = false
				continue
			
			portraits[portrait_name.rstrip(".png")] = portrait
			print("	Successfully loaded portrait\n------------------------------------")
		
		if not load_correct:
			return {}
		
		print("ALL PORTRAITS LOADED SUCESSFULLY!\n")
		return portraits

	func load_all_dialogues(campaign_name : String) -> Dictionary:
		print("#############################\n##### LOADING DIALOGUES #####\n#############################")
		
		var load_correct = true
		var dialogue_files : Array = Utils.scan_files_in_directory("res://campaigns/" + campaign_name + "/dialogues")
		
		if dialogue_files == null:
			load_correct = false
			return {}

		var dialogues := {}
		for dialogue_name in dialogue_files:
			var dialogue_data : Model.Dialogue_Data = load_dialogue(dialogue_name, campaign_name)
			if dialogue_data == null:
				print("\n	Dialogue could not be loaded correctly\n------------------------------------")
				load_correct = false
				continue

			dialogues[dialogue_name.rstrip(".json")] = dialogue_data

		if not load_correct:
			return {}

		print("ALL DIALOGUES LOADED SUCESSFULLY!\n")
		return dialogues
	
	func load_dialogue(dialogue_name : String, campaign_name : String) -> Model.Dialogue_Data:
		print("------------------------------------\nLoading dialogue : " + dialogue_name)
		
		var load_correct := true
		var dialogue_dict = Utils.load_json("res://campaigns/" + campaign_name + "/dialogues/" + dialogue_name)
		
		if dialogue_dict == null:
			load_correct = false
			return null

		if not Validator.dialogue_is_valid(dialogue_dict, dialogue_name):
			load_correct = false
			return null
		
		var dialogue_data := Model.Dialogue_Data.new()
		dialogue_data.name = dialogue_name
		
		# Dialogue nodes
		for dialogue_node_dict in dialogue_dict.dialogue:
			var dialogue_node := Model.Dialogue_Node.new()
			dialogue_node.character = dialogue_node_dict.character
			dialogue_node.text = dialogue_node_dict.text

			if dialogue_node_dict.side != "r" and dialogue_node_dict.side != "l":
				load_correct = false
				print("Dialogue is correct but field side has an invalid value, only \"r\" for right and \"l\" for left are valid")
			dialogue_node.side = dialogue_node_dict.side
			
			# TODO check portrait exists
			if campaign_data.portraits.get(dialogue_node.character) == null:
				load_correct = false
				print("Dialogue is correct, but character \"" + dialogue_node.character + "\" doesn't have a portrait, please make sure the portrait exists and is in the correct place")
				continue
			
			dialogue_data.nodes.append(dialogue_node)
		
		if not load_correct:
			return null
		
		print("	Successfully loaded dialogue\n------------------------------------")
		return dialogue_data

static func load_all_campaigns_basic_info() -> Dictionary:
	var load_correct = true
	var campaign_names : Array = Utils.scan_directories_in_directory("res://campaigns")
	
	if campaign_names == null:
		load_correct = false
		return {}
	
	var campaigns := {}
	for campaign_name in campaign_names:
		var campaign_info = Utils.load_json("res://campaigns/" + campaign_name + "/campaign.json")
		if campaign_info == null:
			load_correct = false
			print("Couldn't find \"campaign.json\" file inside the \"" + campaign_name + "\" campaign, please make sure it exists and is in the correct location")
			continue
		
		if not Validator.campaign_info_is_valid(campaign_info, campaign_name):
			load_correct = false
			continue
		
		campaigns[campaign_name] = campaign_info
	
	if not load_correct:
		return {}
	
	return campaigns
