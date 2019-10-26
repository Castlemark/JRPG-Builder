class_name Model

class Map_Data:
	var name : String
	var navigation_nodes : Array
	var detail_art : Array
	var background_info : BG_Data
	
	class BG_Data:
		var x_offset : float
		var y_offset : float
	
	class Nav_Node_Data:
		var x : float
		var y : float
		var connected_nodes : Array
		var actions : Array
		
		class Action_Data:
			var type : String
			var data
			
			class Travel_Action_Data:
				var map_name : String
				var access_point: int
			
			class Combat_Action_Data:
				# TODO replace with real body
				var dummy
	
	class Detail_Art_Data:
		var x : int
		var y : int
		var rotation : int
		var filepath : String
		var animation_data : Animation_Data

class Item_Data:
		class Consumable_Data:
			var price : int
			var effect : Item_Effect_Data
			
			class Item_Effect_Data:
				var type : String
				var value : int
				var delay : int
				var duration : int
		
		class Quest_Object_Data:
			var keyword : String
		
		class Equipment_Data:
			var price : int
			var slot : String
			var stats : Stats_Data
			var min_level : int
			var rarity : int

class Character_Data:
	var start_level : int
	var min_stats : Stats_Data
	var max_stats : Stats_Data
	var cur_stats: Stats_Data
	var cur_calc_stats : Calc_Stats_Data
	var abilities : Array
	var equipment : Equipment_Data
	var animation_data : Animation_Data
	
	class Equipment_Data:
		var legs : String
		var torso : String
		var accessory_1 : String
		var accessory_2 : String
		var accessory_3 : String
		var weapon : String

class Enemy_Data:
	var stats : Stats_Data
	var calc_stats : Calc_Stats_Data
	var abilities : Array
	var animation_data : Animation_Data

class Ability_Data:
	var min_level : int
	var target_amount : int
	var side : String
	var cost : int
	var delay : int
	var damage : float
	var effect : Ability_Effect_Data
	var hits : int
	var description : String
	
	class Ability_Effect_Data:
		var type : String
		var receiver : String
		var amount : int
		var duration : int

class Stats_Data:
	var strength : int
	var dexterity : int
	var constitution : int
	var memory : int
	var critic : float
	var defence : int
	var alt_defence : int
	var speed : int

class Calc_Stats_Data:
	var hp : int
	var shield : int
	var strain : int
	var evasion : int
	var damage : int

class Animation_Data:
	var hframes : int
	var vframes : int
	var total_frames : int
	var duration : float
	