extends Object

class_name DamageOnTheTile

var damage : int
var turnToTrigger : int
var shouldBeErased: bool
var type: String

func _init(dmg: int, ttt: int, typ: String):
	damage = dmg
	turnToTrigger = ttt
	type = typ
	shouldBeErased = false
