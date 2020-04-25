extends Node

func save():
	var current_scene : Node = $"/root/Game_Manager".current_scene
	if current_scene.name != "Map":
		print("Can't call \"Game_Saver.save()\" when outside of a campaign")
		return
	
	var save_game := Save_Game.new()
	save_game.party = _party_to_info()
	save_game.cur_map = Game_Manager.campaign_data.cur_map
	save_game.cur_access_point = (current_scene as Map).player_avatar.current_node.index
	save_game.completed_actions_nodes = Game_Manager.campaign_data.completed_action_nodes
	
	var error := ResourceSaver.save("user://" + Game_Manager.campaign_data.name + ".tres", save_game)
	if error != OK:
		print("there was an error while trying to save the game")

func load(campaign_name : String):
	print("not yet implemented")
	return null

func _party_to_info() -> Save_Game.Party_Info:
	var party_info := Save_Game.Party_Info.new()
	var party := Game_Manager.campaign_data.party
	
	var fc := Save_Game.Char_Info.new()
	fc.name = party.first_character.name
	fc.cur_xp = party.first_character.cur_xp
	fc.cur_health = party.first_character.stats_with_equipment.health
	
	var fce := Save_Game.Eq_Info.new()
	fce.legs = party.first_character.equipment.legs.name
	fce.torso = party.first_character.equipment.torso.name
	fce.weapon = party.first_character.equipment.weapon.name
	fce.accessory_1 = party.first_character.equipment.accessory_1.name
	fce.accessory_2 = party.first_character.equipment.accessory_2.name
	fce.accessory_3 = party.first_character.equipment.accessory_3.name
	fc.equipment = fce
	
	party_info.first_character = fc
	
	var sc := Save_Game.Char_Info.new()
	sc.name = party.second_character.name
	sc.cur_xp = party.second_character.cur_xp
	sc.cur_health = party.second_character.stats_with_equipment.health
	
	var sce := Save_Game.Eq_Info.new()
	sce.legs = party.second_character.equipment.legs.name
	sce.torso = party.second_character.equipment.torso.name
	sce.weapon = party.second_character.equipment.weapon.name
	sce.accessory_1 = party.second_character.equipment.accessory_1.name
	sce.accessory_2 = party.second_character.equipment.accessory_2.name
	sce.accessory_3 = party.second_character.equipment.accessory_3.name
	sc.equipment = sce
	
	party_info.second_character = sc
	
	var tc := Save_Game.Char_Info.new()
	tc.name = party.third_character.name
	tc.cur_xp = party.third_character.cur_xp
	tc.cur_health = party.third_character.stats_with_equipment.health
	
	var tce := Save_Game.Eq_Info.new()
	tce.legs = party.third_character.equipment.legs.name
	tce.torso = party.third_character.equipment.torso.name
	tce.weapon = party.third_character.equipment.weapon.name
	tce.accessory_1 = party.third_character.equipment.accessory_1.name
	tce.accessory_2 = party.third_character.equipment.accessory_2.name
	tce.accessory_3 = party.third_character.equipment.accessory_3.name
	tc.equipment = tce
	
	party_info.third_character = tc
	
	for item in party.inventory:
		party_info.inventory.append(item.name)
	
	
	return party_info
