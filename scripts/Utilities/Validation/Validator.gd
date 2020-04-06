class_name Validator

# MAP

static func map_is_valid(map_data : Dictionary) -> bool:
	if not Generic_Validators.minimal_info_fields_exist(map_data, Data.Validation.map_fields, "map has missing or incorrect required fields, " + Data.Validation.check_docu, "name"):
		return false
	
	for node in map_data.navigation_nodes:
		if not _nav_node_is_valid(node):
			return false
	
	if not _map_bg_is_valid(map_data.background_info):
		return false
	
	for detail_info in map_data.detail_art:
		if not _map_detail_is_valid(detail_info):
			return false
	
	return true

static func _nav_node_is_valid(node_data : Dictionary) -> bool:
	if Generic_Validators.minimal_info_fields_exist(node_data, Data.Validation.nav_node_fields,  "A navigation node has missing or incorrect required fields, " + Data.Validation.check_docu, ""):
		return true
	return false

static func _map_bg_is_valid(background_info : Dictionary) -> bool:
	if Generic_Validators.minimal_info_fields_exist(background_info, Data.Validation.bg_map_fields, "background_info has missing or incorrect required fields, " + Data.Validation.check_docu, ""):
		return true
	return false

static func _map_detail_is_valid(detail_info : Dictionary) -> bool:
	if Generic_Validators.minimal_info_fields_exist(detail_info, Data.Validation.detail_fields, "detail doesn't have the necessary fields to initialize properly, " + Data.Validation.check_docu, "filepath"):
			return true
	return false

# ENEMY

static func enemy_is_valid(enemy_data, enemy_name : String) -> bool:
	if enemy_data == null:
		return false
	if not Generic_Validators.minimal_info_fields_exist(enemy_data, Data.Validation.enemy_fields, "enemy has missing or incorrect some required fields", "", enemy_name):
		return false
	if not Generic_Validators.minimal_info_fields_exist(enemy_data.stats, Data.Validation.stats, "enemy has missing or incorrect some field in it's \"stats\" field", "", enemy_name):
		return false
	return true

# ABILITY

static func ability_is_valid(ability_data, ability : String) -> bool:
	if ability_data == null:
		return false
	if not Generic_Validators.minimal_info_fields_exist(ability_data, Data.Validation.ability_fields, "ability has missing or incorrect required fields", "", ability):
		return false
	if not Generic_Validators.type_is_valid(ability_data.type, Data.Validation.effect_types, {}):
		return false
	return true


# ITEM

static func item_is_valid(item_data, item : String) -> bool:
	if item_data == null:
		return false
	if not Generic_Validators.minimal_info_fields_exist(item_data, Data.Validation.type_data, "item has missing or incorrect required fields", "", item):
		return false
	if not Generic_Validators.type_is_valid(item_data.type, Data.Validation.item_types, item_data.data):
		return false
	
	var valid := true
	match item_data.type:
		"consumable":
			valid = Generic_Validators.minimal_info_fields_exist(item_data.data.effect, Data.Validation.consumable_effect_fields, "item consumable has missing or incorrect fields in it's \"effect\" field", "", item)
		"equipment":
			valid = Generic_Validators.minimal_info_fields_exist(item_data.data.stats, Data.Validation.stats, "item equipment has missing or incorrect fields in it's \"stats\" field", "", item)
	
	return valid

# EQUIPMENT

static func equipment_is_valid(equipment_data, equipment : String, expected_slot : String) -> bool:
	if equipment_data == null:
		return false
	if not Generic_Validators.minimal_info_fields_exist(equipment_data, Data.Validation.type_data, "item has missing or incorrect required fields", "", equipment):
		return false
	if not Generic_Validators.type_is_valid(equipment_data.type, Data.Validation.item_types, equipment_data.data):
		return false
	if not equipment_data.type == "equipment":
		print("the item is valid but is not an equipment piece, please make sure you try to equip an equipment item")
		return false
	if not Generic_Validators.type_is_valid(equipment_data.data.slot, Data.Validation.equipment_types, equipment_data):
		return false
	if  not (equipment_data.data.slot as String).is_subsequence_of(expected_slot):
		print(equipment + " equipment was valid, but is in a wrong slot, please make sure the equipment is in it's valid slot")
		return false
	return true

# CHARACTER

static func character_is_valid(character_data, character : String) -> bool:
	if character_data == null:
		return false
	if not Generic_Validators.minimal_info_fields_exist(character_data, Data.Validation.char_fields, "character has missing or incorrect required fields", "", character):
		return false
	if not Generic_Validators.minimal_info_fields_exist(character_data.equipment, Data.Validation.char_slots, "character has missing or incorrect required fields in \"equipment\" field", "", character):
		return false
	if not Generic_Validators.minimal_info_fields_exist(character_data.min_stats, Data.Validation.stats, "character has missing or incorrect required fields in \"min_stats\" field", "", character):
		return false
	if not Generic_Validators.minimal_info_fields_exist(character_data.max_stats, Data.Validation.stats, "character has missing or incorrect required fields in \"max_stats\" field", "", character):
		return false
	return true

# DIALOGUE

static func dialogue_is_valid(dialogue_data, dialogue_name : String) -> bool:
	if dialogue_data == null:
		return false
	if not Generic_Validators.minimal_info_fields_exist(dialogue_data, Data.Validation.dialogue_fields, "character has missing or incorrect required fields", "", dialogue_name):
		return false
	for dialogue_node in dialogue_data.dialogue:
		if not Generic_Validators.minimal_info_fields_exist(dialogue_node, Data.Validation.dialogue_node_fields, "character has missing or incorrect required fields", "", dialogue_name):
			return false
		if not Generic_Validators.type_is_valid(dialogue_node.side, Data.Validation.dialogue_node_side_types, {}):
			return false
	return true

static func campaign_info_is_valid(campaign_info_data, campaign_name) -> bool:
	if campaign_info_data == null:
		return false
	if not Generic_Validators.minimal_info_fields_exist(campaign_info_data, Data.Validation.campaign_info_data, "campaign has missing or incorrect required fields", "", campaign_name):
		return false
	if campaign_info_data.access_point < 0:
		print("campaign info \"" + campaign_name + "/campaign.json\" is valid, but it's \"access_point\" property is smaller than 0, please make sure \"access_point\" is correct")
		return false
	if campaign_info_data.party.size() > 3 or campaign_info_data.party.size() <= 0:
		print("campaign info \"" + campaign_name + "/campaign.json\" is valid, but it's \"party\" property must have a size between 1 and 3, please make sure \"party\" is correct")
		return false
	return true
