extends CharacterBody2D

var health: int
var passive: String
var actions: Array
@export var healthText: Control

func SetIntialValues(h, p, a):
	health = h
	passive = p
	actions = a
	healthText.text = str(health)

func TakeDamage(damage):
	health -= damage
	if health <= 0:
		health = 0
		queue_free()
	healthText.text = str(health)
