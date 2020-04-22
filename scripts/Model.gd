class_name Model

class Campaign_Data:
	var name : String

	var maps : Dictionary
	var cur_map : String

	var items : Dictionary
	var abilities : Dictionary

	var characters: Dictionary
	var npcs : Dictionary
	var enemies : Dictionary
	
	var portraits : Dictionary
	var dialogues : Dictionary
	
	var cutscenes : Dictionary

	var party : Party_Data

class Party_Data:
	var first_character : Character_Data
	var second_character : Character_Data
	var third_character : Character_Data

	var inventory : Array


class Map_Data:
	var name : String
	var navigation_nodes : Array
	var detail_art : Array
	var background_info : BG_Data
	var access_point : int
	var avatar_scale : float

	var combat_background : Texture
	var map_floor : Texture
	var intersection_texture : Texture
	var path_texture : Texture
	var between_texture : Texture
	var avatar_texture : Texture

	class BG_Data:
		var x_offset : float
		var y_offset : float
		var color : Color
		var scale : float

	class Nav_Node_Data:
		var x : float
		var y : float
		var connected_nodes : Array
		var actions : Array

		class Action_Data:
			var type : String
			var data : Dictionary

	class Detail_Art_Data:
		var x : float
		var y : float
		var scale : float
		var rotation : int
		var filepath : String
		var animation_data : Animation_Data

		var texture : Texture

class Item_Data:
		class Consumable_Data:
			var type : String
			var name : String
			var effect : Item_Effect_Data
			var description : String

			var icon_texture : Texture

			class Item_Effect_Data:
				var type : String
				var value : int

				var icon_texture : Texture

		class Equipment_Item_Data:
			var type : String
			var name : String
			var slot : String
			var stats : Stats_Data
			var min_level : int
			var rarity : int
			var description : String

			var icon_texture : Texture

class Character_Data:
	var name : String
	var cur_xp : int
	var min_stats : Stats_Data
	var max_stats : Stats_Data
	var stats : Stats_Data
	var stats_with_equipment : Stats_Data
	var abilities : Dictionary
	var equipment : Equipment_Data
	var animation_data : Animation_Data
	var scale : float

	var icon_texture : Texture
	var idle_texture : Texture
	var attack_texture : Texture
	var hit_texture : Texture
	var miss_texture : Texture

	func cur_level() -> int:
		return floor(self.cur_xp/100.0) as int
	
	func stats_with_eq(equipment : Equipment_Data, max_everything : bool = false) -> Model.Stats_Data:
		var eq_stats := Stats_Data.new()

		eq_stats.max_health = max(stats.max_health + equipment.legs.stats.health + equipment.torso.stats.health + equipment.accessory_1.stats.health + equipment.accessory_2.stats.health + equipment.accessory_3.stats.health + equipment.weapon.stats.health, 10)
		eq_stats.health = eq_stats.max_health if max_everything else int(max(stats.health, 0))
		eq_stats.max_damage = max(stats.max_damage + equipment.legs.stats.damage + equipment.torso.stats.damage + equipment.accessory_1.stats.damage + equipment.accessory_2.stats.damage + equipment.accessory_3.stats.damage + equipment.weapon.stats.damage, 0)
		eq_stats.damage = eq_stats.max_damage if max_everything else int(max(stats.damage, 0))
		eq_stats.max_strain = max(stats.max_strain + equipment.legs.stats.strain + equipment.torso.stats.strain + equipment.accessory_1.stats.strain + equipment.accessory_2.stats.strain + equipment.accessory_3.stats.strain + equipment.weapon.stats.strain, 0)
		eq_stats.strain = eq_stats.max_strain if max_everything else int(max(stats.strain, 0))
		eq_stats.max_evasion = clamp(stats.max_evasion + equipment.legs.stats.evasion + equipment.torso.stats.evasion + equipment.accessory_1.stats.evasion + equipment.accessory_2.stats.evasion + equipment.accessory_3.stats.evasion + equipment.weapon.stats.evasion, 0, 1)
		eq_stats.evasion = eq_stats.max_evasion if max_everything else max(stats.evasion, 0)
		eq_stats.critic = clamp(stats.critic + equipment.legs.stats.critic + equipment.torso.stats.critic + equipment.accessory_1.stats.critic + equipment.accessory_2.stats.critic + equipment.accessory_3.stats.critic + equipment.weapon.stats.critic, 0, 1)
		eq_stats.speed = max(stats.speed + equipment.legs.stats.speed + equipment.torso.stats.speed + equipment.accessory_1.stats.speed + equipment.accessory_2.stats.speed + equipment.accessory_3.stats.speed + equipment.weapon.stats.speed, 0)

		return eq_stats
	
	func calc_diff(new_eq : Equipment_Data) -> Stats_Data:
		var diff_stats := stats_with_eq(new_eq)
		var cur_stats := stats_with_eq(equipment)

		diff_stats.max_health -= cur_stats.max_health
		diff_stats.max_damage -= cur_stats.max_damage
		diff_stats.max_strain -= cur_stats.max_strain
		diff_stats.max_evasion -= cur_stats.max_evasion
		diff_stats.critic -= cur_stats.critic
		diff_stats.speed -= cur_stats.speed

		return diff_stats


	class Equipment_Data:
		var legs : Item_Data.Equipment_Item_Data
		var torso : Item_Data.Equipment_Item_Data
		var accessory_1 : Item_Data.Equipment_Item_Data
		var accessory_2 : Item_Data.Equipment_Item_Data
		var accessory_3 : Item_Data.Equipment_Item_Data
		var weapon : Item_Data.Equipment_Item_Data
		
		func duplicate_eq() -> Model.Character_Data.Equipment_Data:
			var eq_data := Equipment_Data.new()
			
			eq_data.legs = legs
			eq_data.torso = torso
			eq_data.accessory_1 = accessory_1
			eq_data.accessory_2 = accessory_2
			eq_data.accessory_3 = accessory_3
			eq_data.weapon = weapon
			
			return eq_data

class Enemy_Data:
	var name : String
	var stats_with_equipment : Stats_Data
	var abilities : Dictionary
	var animation_data : Animation_Data
	var xp_reward : int
	var scale : float

	var icon_texture : Texture
	var idle_texture : Texture
	var attack_texture : Texture
	var hit_texture : Texture
	var miss_texture : Texture

	func duplicate_enemy() -> Enemy_Data:
		var d_enemy := Enemy_Data.new()
		d_enemy.name = self.name
		d_enemy.stats_with_equipment = self.stats_with_equipment.duplicate_stats()
		d_enemy.animation_data = self.animation_data
		d_enemy.abilities = self.abilities
		d_enemy.scale = self.scale
		d_enemy.xp_reward = self.xp_reward

		d_enemy.icon_texture = self.icon_texture
		d_enemy.idle_texture = self.idle_texture
		d_enemy.attack_texture = self.attack_texture
		d_enemy.hit_texture = self.hit_texture
		d_enemy.miss_texture = self.miss_texture

		return d_enemy

class Ability_Data:
	var name : String
	var min_level : int
	var side : String
	var cost : int
	var amount : float
	var type : String
	var description : String
	var icon_texture : Texture

class Stats_Data:
	var critic : float
	var speed : int
	var health : int
	var max_health : int
	var strain : int
	var max_strain : int
	var evasion : float
	var max_evasion : float
	var damage : int
	var max_damage : int

	func duplicate_stats() -> Stats_Data:
		var d_stats := Stats_Data.new()

		d_stats.critic = self.critic
		d_stats.speed = self.speed
		d_stats.health = self.health
		d_stats.max_health = self.max_health
		d_stats.strain = self.strain
		d_stats.max_strain = self.max_strain
		d_stats.evasion = self.evasion
		d_stats.max_evasion = self.max_evasion
		d_stats.damage = self.damage
		d_stats.max_damage = self.max_damage

		return d_stats

class Dialogue_Data:
	var name : String
	var nodes : Array

class Dialogue_Node:
	var character : String
	var side : String
	var text : String

class Cutscene_Data:
	var name : String
	var nodes : Array

class Cutscene_Node:
	var text : String
	var image : Texture

class Animation_Data:
	var hframes : int
	var vframes : int
	var total_frames : int
	var duration : float
