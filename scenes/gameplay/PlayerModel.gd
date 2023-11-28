extends CharacterBody2D

@export var gameController: Node

var health = 100
var guard = 0
var isMoving = false

func TakeDamage(damage):
	health -= damage
	if health <= 0:
		health = 0
		queue_free()
	gameController.playerHp.text = str(health)
