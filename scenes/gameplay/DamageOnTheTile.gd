extends Object

class_name DamageOnTheTile

var damage : int
var turnToTrigger : int
var shouldBeErased: bool

func _init(dmg: int, ttt: int):
	damage = dmg
	turnToTrigger = ttt
	shouldBeErased = false
