extends CharacterBody2D

var gameController: Node
@export var healthText: Control
@export var popup: PackedScene

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
			Popup("FlyFast", 60)
			return
		elif type == "Fast":
			passive = ""
			Popup("Broken FlyFast", 60)
			
	if id == 2 && passive == "Shield":
		if type == "Fast":
			Popup("Shield", 60)
			return
		elif type == "Slow":
			passive = ""
			Popup("Broken Shield", 60)
		
	health -= damage
	
	if health <= 0:
		health = 0
		gameController.enemies.erase(self)
		if gameController.enemies.is_empty():
			gameController.FinishGame()
		queue_free()
	healthText.text = str(health)


func Popup(value, offset):
	var popupInstance = popup.instantiate()
	popupInstance.get_node("Label").text = value
	popupInstance.position = global_position - Vector2(0, offset)
	
	get_tree().current_scene.add_child(popupInstance)
