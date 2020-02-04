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

class Item_Data:
		class Consumable_Data:
			var type : String
			var name : String
			var price : int
			var effect : Item_Effect_Data

			class Item_Effect_Data:
				var type : String
				var value : int
				var delay : int
				var duration : int

		class Quest_Object_Data:
			var type : String
			var name : String
			var keyword : String

		class Equipment_Item_Data:
			var type : String
			var name : String
			var price : int
			var slot : String
			var stats : Stats_Data
			var min_level : int
			var rarity : int

class Character_Data:
	var name : String
	var start_level : int
	var cur_level : int
	var min_stats : Stats_Data
	var max_stats : Stats_Data
	var stats : Stats_Data
	var abilities : Dictionary
	var equipment : Equipment_Data
	var animation_data : Animation_Data
	var scale : float

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

class Animation_Data:
	var hframes : int
	var vframes : int
	var total_frames : int
	var duration : float
