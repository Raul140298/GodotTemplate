extends CharacterBody2D

@export var healthText: Control

var id: int
var health: int
var passive: String
var actionsPerTurn = 0

func SetIntialValues(h, p, i):
	health = h
	passive = p
	id = i
	healthText.text = str(health)


func SetActionsPerTurn():
	if passive == "FlyFast":
		actionsPerTurn = 2
	else:
		actionsPerTurn = 1


func TakeDamage(damage):
	health -= damage
	if health <= 0:
		health = 0
		queue_free()
	healthText.text = str(health)
