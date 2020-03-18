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

	var party : Party_Data

class Party_Data:
	var first_character : Character_Data
	var second_character : Character_Data
	var third_character : Character_Data

	var inventory : Array
	var money : int


class Map_Data:
	var name : String
	var navigation_nodes : Array
	var detail_art : Array
	var background_info : BG_Data
	var access_point : int

	var combat_background : Texture
	var map_floor : Texture
	var intersection_texture : Texture
	var path_texture : Texture
	var between_texture : Texture
	var avatar_texture : Texture

	class BG_Data:
		var x_offset : float
		var y_offset : float
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
			var price : int
			var effect : Item_Effect_Data

			var icon_texture : Texture

			class Item_Effect_Data:
				var type : String
				var value : int
				var delay : int
				var duration : int

				var icon_texture : Texture

		class Quest_Object_Data:
			var type : String
			var name : String
			var keyword : String

			var icon_texture : Texture

		class Equipment_Item_Data:
			var type : String
			var name : String
			var price : int
			var slot : String
			var stats : Stats_Data
			var min_level : int
			var rarity : int

			var icon_texture : Texture

class Character_Data:
	var name : String
	var start_xp : int
	var cur_xp : int
	var min_stats : Stats_Data
	var max_stats : Stats_Data
	var stats : Stats_Data
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

	class Equipment_Data:
		var legs : Item_Data.Equipment_Item_Data
		var torso : Item_Data.Equipment_Item_Data
		var accessory_1 : Item_Data.Equipment_Item_Data
		var accessory_2 : Item_Data.Equipment_Item_Data
		var accessory_3 : Item_Data.Equipment_Item_Data
		var weapon : Item_Data.Equipment_Item_Data

class Enemy_Data:
	var name : String
	var stats : Stats_Data
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
		d_enemy.stats = self.stats.duplicate_stats()
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
	var text : String

class Animation_Data:
	var hframes : int
	var vframes : int
	var total_frames : int
	var duration : float
