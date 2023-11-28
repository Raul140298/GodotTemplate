extends Node

@export var player: Node2D
@export var btnAction1: Control
@export var btnAction2: Control
@export var btnAction3: Control
@export var btnFinishTurn: Control
@export var playerHp: Control 
@export var actionsPerTurnText: Control
@export var movementsPerActionText: Control
@export var turnText: Control 
@export var tiles: Array = []

signal turnChanged

var turn = 0
var actionsPerTurn = 0

var actionsList =[0,1,2,3,4]
var actions = ["ShootFast", "ShootSlow", "Movement", "Health", "Guard"]
var steps = [1,1,2,1,1]
var actionsConsume = [1,2,1,1,1]

var actionsAvailable = []
var stepsAvailable = []

var possibleNewTurn = 0

var enemies = []
var tweensInProcess = []


func _ready():
	SetPlayer()
	SetEnemies()
	StartPlayerTurn()


func SetPlayer():
	SetPlayerPosition()
	playerHp.text = str(player.health)	
	player.get_node("AnimationPlayer").play("idle_right")


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
		enemy_instance.SetIntialValues(initialValues.health, initialValues.passive, initialValues.id)
		SetEnemyPosition(enemy_instance)
		enemy_instance.get_node("AnimationPlayer").play("idle_left")
		
		enemies.append(enemy_instance)


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
	if turn == possibleNewTurn:
		StartPlayerTurn()
	else:
		StartEnemiesTurn()


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
		player.guard += 50
		turnChanged.connect(Callable(OnPlayerGuardSignal.bind(turn+2)))


func OnPlayerGuardSignal(lastTurn):
		if turn == lastTurn:
			player.guard = 0
			turnChanged.disconnect(OnPlayerGuardSignal)


func RandomizeActions():
	var aux = actionsList
	aux.shuffle()
	actionsAvailable = aux.slice(0,3)
	btnAction1.text = actions[actionsAvailable[0]] + " (" + str(actionsConsume[actionsAvailable[0]]) + ")"
	btnAction2.text = actions[actionsAvailable[1]] + " (" + str(actionsConsume[actionsAvailable[1]]) + ")"
	btnAction3.text = actions[actionsAvailable[2]] + " (" + str(actionsConsume[actionsAvailable[2]]) + ")"

	btnAction1.show()
	btnAction2.show()
	btnAction3.show()
	btnFinishTurn.show()


func StartPlayerTurn():
	actionsPerTurn = 2
	actionsPerTurnText.text = str(actionsPerTurn)
	stepsAvailable = [0,0,0,0,0]
	RandomizeActions()
	possibleNewTurn = turn + 2
	
	NextTurn()


func StartEnemiesTurn():
	btnAction1.hide()
	btnAction2.hide()
	btnAction3.hide()
	btnFinishTurn.hide()
	
	actionsPerTurn = 0
	actionsPerTurnText.text = str(actionsPerTurn)
	stepsAvailable = [0,0,0,0,0]
	movementsPerActionText.text = str(0)
	
	NextTurn()
	
	enemies.shuffle()
	
	for enemy in enemies:
		ChooseEnemyAction(enemy)
		
	for tween in tweensInProcess:
		await tween.finished
		
	FinishTurn()


func ChooseEnemyAction(enemy):
	var r = randi() % 2
	
	if r == 0:
		MoveEnemy(enemy)
	else:
		EnemyShootPlayer(enemy)


func EnemyShootPlayer(enemy):
	var x = (player.transform.origin.x-64)/128
	var y = (player.transform.origin.y-64)/128
	
	var tileToShoot = get_node(tiles[x][y])
	
	if tileToShoot.guest == player:
		tileToShoot.DamageTile(10, turn, 2)


func MoveEnemy(enemy):
	var x = (enemy.transform.origin.x-64)/128
	var y = (enemy.transform.origin.y-64)/128
	
	var tilesAvailables = []
	
	var iX
	var iY
	
	#UP
	iX = x
	iY = y + 1
	
	if iY < 5 && get_node(tiles[iX][iY]).guest == null:
		tilesAvailables.append(get_node(tiles[iX][iY]))
		
	#DOWN
	iX = x
	iY = y - 1
	
	if iY >= 0 && get_node(tiles[iX][iY]).guest == null:
		tilesAvailables.append(get_node(tiles[iX][iY]))
		
	#RIGHT
	iX = x + 1
	iY = y
	
	if iX < 8 && get_node(tiles[iX][iY]).guest == null:
		tilesAvailables.append(get_node(tiles[iX][iY]))
		
	#LEFT
	iX = x - 1
	iY = y
	
	if iX >= 4 && get_node(tiles[iX][iY]).guest == null:
		tilesAvailables.append(get_node(tiles[iX][iY]))
	
	if tilesAvailables.is_empty():
		return
	else:
		var tileOrigin = get_node(tiles[x][y])
		if tileOrigin.guest == enemy:
			tileOrigin.guest = null
		
		var tileTarget = tilesAvailables[randi() % tilesAvailables.size()]
		tileTarget.guest = enemy
		MoveUnit(tileTarget.transform.origin.x, tileTarget.transform.origin.y, enemy)


func NextTurn():
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


func MovePlayer(tileTarget):
	var x = (player.transform.origin.x-64)/128
	var y = (player.transform.origin.y-64)/128
	
	var tileOrigin = get_node(tiles[x][y])
	if tileOrigin.guest == player:
		tileOrigin.guest = null
	
	tileTarget.guest = player
	MoveUnit(tileTarget.transform.origin.x, tileTarget.transform.origin.y, player)

 
func MoveUnit(x, y, unit):
	StartActionPerTurn(2)
	
	var direction = Vector2i.ZERO
	
	if(y > unit.transform.origin.y && x == unit.transform.origin.x):
		direction = Vector2i.DOWN
	elif (y < unit.transform.origin.y && x == unit.transform.origin.x):
		direction = Vector2i.UP
	elif (x > unit.transform.origin.x && y == unit.transform.origin.y):
		direction = Vector2i.RIGHT
	elif (x < unit.transform.origin.x && y == unit.transform.origin.y):
		direction = Vector2i.LEFT
	
	unit.get_node("AnimationPlayer").play("walk" + GetDirectionSuffix(direction))
	
	var targetPosition = unit.position + direction * 128.0
	var tween = create_tween()
	
	tween.tween_property(unit, "position", targetPosition, 0.5)
	
	tweensInProcess.append(tween)
	
	await tween.finished
	
	tweensInProcess.erase(tween)
	
	unit.get_node("AnimationPlayer").play("idle" + GetDirectionSuffix(direction))
	
	var tile = get_node(tiles[(unit.transform.origin.x-64)/128][(unit.transform.origin.y-64)/128])
	var mousePos = tile.GetMousePosition()
	var mouseTileX = int(mousePos.x/128)
	var mouseTileY = int(mousePos.y/128)
	
	if mouseTileX >= 0 && mouseTileX < 8 && mouseTileY >= 0 && mouseTileY < 5:
		tile = get_node(tiles[int(mousePos.x/128)][int(mousePos.y/128)])
		tile.HoverTile()
 

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
