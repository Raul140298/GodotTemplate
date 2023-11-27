extends CharacterBody2D

var health: int
var passive: String
var actions: Array

func SetIntialValues(h, p, a):
	health = h
	passive = p
	actions = a

func TakeDamage(damage):
	health -= damage
	if health <= 0:
		health = 0
		queue_free()
