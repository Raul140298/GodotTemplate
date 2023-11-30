extends CharacterBody2D

@export var gameController: Node

var health = 100
var guard = 0
var isMoving = false

func TakeDamage(damage, type):
	if guard > 0:
		health -= damage * guard / 100;
	else:
		health -= damage
		
	gameController.playerHp.text = str(health)
	
	if health <= 0:
		health = 0
		gameController.playerHp.text = str(health)
		gameController.FinishGame()
		queue_free()
