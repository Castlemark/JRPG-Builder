class_name Data

class Validation:

	# ALLOWED VARIABLE TYPES
	const NUMBER = 3
	const TEXT = 4
	const DICTIONARY = 18
	const ARRAY = 19

	const check_docu := "please check the documentation to know the necessary fields"

	const action_types := {
		"travel" : [{"map_name" : TEXT}, {"access_point" : NUMBER}],
		"combat" : [{"enemies" : ARRAY}],
		"treasure": [{"items": ARRAY}],
		"dialogue": [{"id": TEXT}],
		"cutscene": [{"id": TEXT}],
		"wait": [{"amount": NUMBER}]
	}

	const item_types := {
		"consumable" : [{"effect" : DICTIONARY}, {"description": TEXT}],
		"equipment" : [{"slot" : TEXT}, {"stats" : DICTIONARY}, {"min_level" : NUMBER}, {"rarity" : NUMBER}, {"description": TEXT}]
	}

	const equipment_types := {
		"legs" : [],
		"torso" : [],
		"accessory" : [],
		"weapon" : []
	}

	const effect_types := {
		"health": [],
		"damage": [],
		"evasion": [],
		"strain": []
	}

	const receiver_types := {
		"same": [],
		"complementary": [],
		"opposite": []
	}

	const dialogue_node_side_types := {
		"l": [],
		"r": []
	}

	# CAMPAIGN
	const campaign_info_data := [{"map_name" : TEXT}, {"access_point" : NUMBER}, {"party" : ARRAY}, {"inventory" : ARRAY}, {"description" : TEXT}]

	# GENERAL
	const animation_data := [{"hframes" : NUMBER}, {"vframes" : NUMBER}, {"total_frames" : NUMBER}, {"duration" : NUMBER}]
	const type_data := [{"type" : TEXT}, {"data" : DICTIONARY}] # Used for items and actions

	# CHARACTER
	const char_fields := [{"start_xp" : NUMBER}, {"min_stats" : DICTIONARY}, {"max_stats" : DICTIONARY}, {"abilities" : ARRAY}, {"equipment" : DICTIONARY}, {"scale": NUMBER}]
	const stats := [{"critic" : NUMBER}, {"speed" : NUMBER}, {"health" : NUMBER}, {"strain" : NUMBER}, {"evasion" : NUMBER}, {"evasion" : NUMBER}]
	const char_slots := [{"legs" : TEXT}, {"torso" : TEXT}, {"accessory_1" : TEXT}, {"accessory_2" : TEXT}, {"accessory_3" : TEXT}, {"weapon" : TEXT}]

	# ABILITY
	const ability_fields := [ {"min_level" : NUMBER}, {"side" : TEXT}, {"cost" : NUMBER}, {"type" : TEXT}, {"amount" : NUMBER}, {"description" : TEXT},]

	# ITEM
	const consumable_effect_fields := [{"type" : TEXT}, {"value" : NUMBER}]

	# MAP
	const map_fields := [{"navigation_nodes" : ARRAY}, {"detail_art" : ARRAY}, {"background_info" : DICTIONARY}, {"name" : TEXT}]
	const nav_node_fields := [{"x" : NUMBER}, {"y" : NUMBER}, {"connected_nodes" : ARRAY}, {"actions" : ARRAY}]
	const bg_map_fields := [{"x_offset" : NUMBER}, {"y_offset" : NUMBER}, {"scale": NUMBER}]
	const detail_fields := [{"x" : NUMBER}, {"y" : NUMBER}, {"scale": NUMBER}, {"rotation" : NUMBER}, {"filepath" : TEXT}]

	# ENEMY
	const enemy_fields := [{"stats" : DICTIONARY}, {"abilities" : ARRAY}, {"xp_reward": NUMBER}, {"scale": NUMBER}]

	# DIALOGUE
	const dialogue_fields := [{"dialogue" : ARRAY}]
	const dialogue_node_fields := [{"character" : TEXT}, {"text": TEXT}, {"side": TEXT}]
	
	# CUTSCENE
	const cutscene_fields := [{"cutscene" : ARRAY}]
	const cutscene_node_fields := [{"text" : TEXT}, {"image" : TEXT}]
