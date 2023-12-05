extends CharacterBody2D

@export var gameController: Node
@export var popup: PackedScene

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


func Popup(value, offset):
	var popupInstance = popup.instantiate()
	popupInstance.get_node("Label").text = value
	popupInstance.position = global_position - Vector2(0, offset)
	
	get_tree().current_scene.add_child(popupInstance)
