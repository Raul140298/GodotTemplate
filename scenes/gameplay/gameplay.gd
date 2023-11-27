extends Node

@export var player: Node2D
@export var btnAction1: Control
@export var btnAction2: Control
@export var btnAction3: Control
@export var playerHp: Control 
@export var actionsPerTurnText: Control
@export var movementsPerActionText: Control
@export var turnText: Control 
@export var tiles: Array = []

signal turnChanged

var turn = 0
var actionsPerTurn = 2

var actionsList =[0,1,2,3,4]
var actions = ["ShootFast", "ShootSlow", "Movement", "Health", "Guard"]
var steps = [1,1,2,1,1]
var actionsConsume = [1,2,1,1,1]

var actionsAvailable = []
var stepsAvailable = []

func _ready():
	SetPlayer()
	SetEnemies()
	StartTurn()
	
	
func SetPlayer():
	SetPlayerPosition()
	player.get_node("AnimationPlayer").play("idle_right")
	playerHp.text = str(player.health)	
	
func SetPlayerPosition():
	var x = randi() % 4
	var y = randi() % 5
	
	player.transform.origin.x = x * 128 + 64
	player.transform.origin.y = y * 128 + 64

	get_node(tiles[x][y]).guest = player
	

func SetEnemies():
	for i in range(3):
		var scene = preload("res://scenes/gameplay/enemy.tscn")
		var initialValues
		
		if i == 0:
			initialValues = preload("res://scenes/gameplay/RES_Enemy1.tres")
		elif i == 1:
			initialValues = preload("res://scenes/gameplay/RES_Enemy2.tres")
		elif i == 2:
			initialValues = preload("res://scenes/gameplay/RES_Enemy3.tres")
		
		var enemy_instance = scene.instantiate()
		enemy_instance.set_name("Enemy " + str(i))
		add_child(enemy_instance)
		enemy_instance.SetIntialValues(initialValues.health, initialValues.passive, initialValues.actions)
		SetEnemyPosition(enemy_instance)
		enemy_instance.get_node("AnimationPlayer").play("idle_left")

func SetEnemyPosition(enemy):
	var x = -1
	var y = -1

	while true:
		x = randi() % 4 + 4
		y = randi() % 5
		if get_node(tiles[x][y]).guest == null:
			break

	enemy.transform.origin.x = x * 128 + 64
	enemy.transform.origin.y = y * 128 + 64

	get_node(tiles[x][y]).guest = enemy
	

func FinishTurn():
	StartTurn()
	
	
func SelectAction(id):
	if actionsPerTurn > 0:
		ActionChosen(id)
		
	
func ActionChosen(id):
	if actionsPerTurn > 0 && actionsPerTurn <actionsConsume[actionsAvailable[id]]:
		return
	
	btnAction1.hide()
	btnAction2.hide()
	btnAction3.hide()
	
	actionsPerTurn -= actionsConsume[actionsAvailable[id]]
	actionsPerTurnText.text = str(actionsPerTurn)
	stepsAvailable[actionsAvailable[id]] += steps[actionsAvailable[id]]
	
	if actionsAvailable[id] == 2:
		movementsPerActionText.text = str(stepsAvailable[2])
	
	InstantAction(actionsAvailable[id])
	

func OnActionFinished():
	if actionsPerTurn > 0:
		RandomizeActions()
		
func InstantAction(id):
	if id == 3 && stepsAvailable[3] > 0:
		StartActionPerTurn(3)
		player.health += 25
		if player.health > 100:
			player.health = 100
		playerHp.text = str(player.health)
		
	if id == 4 && stepsAvailable[4] > 0:
		StartActionPerTurn(4)
		
	
func RandomizeActions():
	var aux = actionsList
	aux.shuffle()
	actionsAvailable = aux.slice(0,3) #Arreglo de 3 ids desordenados
	btnAction1.text = actions[actionsAvailable[0]] + " (" + str(actionsConsume[actionsAvailable[0]]) + ")"
	btnAction2.text = actions[actionsAvailable[1]] + " (" + str(actionsConsume[actionsAvailable[1]]) + ")"
	btnAction3.text = actions[actionsAvailable[2]] + " (" + str(actionsConsume[actionsAvailable[2]]) + ")"

	btnAction1.show()
	btnAction2.show()
	btnAction3.show()


func StartTurn():
	actionsPerTurn = 2
	actionsPerTurnText.text = str(actionsPerTurn)
	stepsAvailable = [0,0,0,0,0]
	RandomizeActions()
	turn += 1
	turnText.text = str(turn)
	turnChanged.emit()
	
func StartActionPerTurn(id):
	if stepsAvailable[id] > 0:
		stepsAvailable[id] -= 1
		
	if id == 2:
		movementsPerActionText.text = str(stepsAvailable[2])
	
	if stepsAvailable[id] == 0:
		OnActionFinished()	
			
 
func MovePlayer(x, y):
	player.isMoving = true
	
	StartActionPerTurn(2)
	
	get_node(tiles[(player.transform.origin.x-64)/128][(player.transform.origin.y-64)/128]).guest = null
	
	var direction = Vector2i.ZERO
	
	if(y > player.transform.origin.y && x == player.transform.origin.x):
		direction = Vector2i.DOWN
	elif (y < player.transform.origin.y && x == player.transform.origin.x):
		direction = Vector2i.UP
	elif (x > player.transform.origin.x && y == player.transform.origin.y):
		direction = Vector2i.RIGHT
	elif (x < player.transform.origin.x && y == player.transform.origin.y):
		direction = Vector2i.LEFT
	
	player.get_node("AnimationPlayer").play("walk" + GetDirectionSuffix(direction))
	
	var targetPosition = player.position + direction * 128.0
	var tween = create_tween()
	
	tween.tween_property(player, "position", targetPosition, 0.5)
	
	await tween.finished
	
	player.get_node("AnimationPlayer").play("idle" + GetDirectionSuffix(direction))
	get_node(tiles[(player.transform.origin.x-64)/128][(player.transform.origin.y-64)/128]).guest = player
	player.isMoving = false
 
func GetDirectionSuffix(direction):
	if direction == Vector2i.RIGHT:
		return "_right"
	elif direction == Vector2i.LEFT:
		return "_left"
	elif direction == Vector2i.DOWN:
		return "_down"
	elif direction == Vector2i.UP:
		return "_up"
	return "_left"


func _on_action_1_pressed():
	SelectAction(0)


func _on_action_2_pressed():
	SelectAction(1)


func _on_action_3_pressed():
	SelectAction(2)


func _on_finish_turn_pressed():
	FinishTurn()
