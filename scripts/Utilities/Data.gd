class_name Data

class Validation:
	
	const check_docu := "please check the documentation to know the necessary fields"
	
	const action_types := {
		"travel" : ["map_name", "access_point"],
		"combat" : []
	}
	const item_types := {
		"consumable" : ["price", "effect"],
		"equipment" : ["price", "slot", "stats", "min_level", "rarity"],
		"quest_object" : ["keyword"]
	}
	
	const equipment_types := {
		"legs" : [],
		"torso" : [],
		"accessory" : [],
		"weapon" : []
	}
	
	const effect_types := {
		"strength": [], "dexterity": [], "constitution": [], "memory": [], "critic": [], "defence": [], "alt_defence": [], "speed": [],
		"health": [],
		"evasion": [],
		"shield": [],
		"strain": [],
		"none": []
	}
	
	const receiver_types := {
		"same": [],
		"complementary": [],
		"opposite": []
	}
	
	# GENERAL
	const animation_data := ["hframes", "vframes", "total_frames", "duration"]
	const type_data := ["type", "data"] # Used for items and actions
	
	# CHARACTER
	const char_fields := ["start_level", "min_stats", "max_stats", "abilities", "equipment"]
	const stats := ["strength", "dexterity", "constitution", "critic", "defence", "alt_defence", "speed"]
	const char_slots := ["legs", "torso", "accessory_1", "accessory_2", "accessory_3", "weapon"]
	
	# ABILITY
	const ability_fields := [ "min_level", "target_amount", "side", "cost", "delay", "damage", "effect", "hits", "description"]
	const ability_effect_fields := ["type", "receiver", "amount", "duration"]
	
	# ITEM
	const item_effect_fields := ["type", "value", "delay", "duration"]
	
	# MAP
	const map_fields := ["navigation_nodes", "detail_art", "background_info", "name"]
	const nav_node_fields := ["x", "y", "connected_nodes", "actions"]
	const bg_map_fields := ["x_offset", "y_offset"]
	const detail_fields := ["x", "y", "rotation", "filepath"]
	
	# ENEMY
	const enemy_fields := ["stats", "abilities"]
	
	