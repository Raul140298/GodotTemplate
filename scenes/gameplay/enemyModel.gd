extends CharacterBody2D

var gameController: Node
@export var healthText: Control

var id: int
var health: int
var passive: String
var actionsPerTurn = 0
var turnsToWait = 0

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


func TakeDamage(damage, type):
	print(type)
	
	if id == 1 && passive == "FlyFast":
		if type == "Slow":
			return
		elif type == "Fast":
			passive = ""
			
	if id == 2 && passive == "Shield":
		if type == "Fast":
			return
		elif type == "Slow":
			passive = ""
		
	health -= damage
	if health <= 0:
		health = 0
		gameController.enemies.erase(self)
		if gameController.enemies.is_empty():
			gameController.FinishGame()
		queue_free()
	healthText.text = str(health)
