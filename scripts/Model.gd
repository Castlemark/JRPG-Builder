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
	var cur_stats : Stats_Data
	var cur_calc_stats : Calc_Stats_Data
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
	var calc_stats : Calc_Stats_Data
	var abilities : Dictionary
	var animation_data : Animation_Data
	var scale : float

class Ability_Data:
	var name : String
	var min_level : int
	var target_amount : int
	var side : String
	var cost : int
	var delay : int
	var damage : float
	var effect : Ability_Effect_Data
	var hits : int
	var description : String
	var scale : float
	
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