extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartsUIFull = $HeartsUIFull
onready var heartsUIEmpty = $HeartsUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartsUIFull != null:
		heartsUIFull.rect_size.x = hearts * 15
	
func set_max_hearts(value):
	max_hearts = clamp(value, 1, value)
	self.hearts = min(hearts, max_hearts)
	if heartsUIFull != null:
		heartsUIFull.rect_size.x = hearts * 15
	
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = max_hearts
	heartsUIEmpty.rect_size.x = hearts * 15
	heartsUIFull.rect_size.x = hearts * 15
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
