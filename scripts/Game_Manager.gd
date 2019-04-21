extends Node


#warning-ignore:unused_class_variable
var campaign_name : String = "example_campaign"

func _ready():
	var campaign_data : Dictionary = Utils.load_json("res://campaigns/example_campaign/campaign.json")
	($"/root/Map" as Map).initialize(campaign_data.map_name as String, campaign_data.acces_point as int)