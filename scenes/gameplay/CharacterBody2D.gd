extends CharacterBody2D
 
var isMoving = false
var actionsPerTurn = 2
var health = 100
var guard = 0
var actionsList =[0,1,2,3,4]
var actions = ["ShootFast", "ShootSlow", "Movement", "Health", "Guard"]
var steps = [1,1,2,1,1]
var actionsAvailable = []
var stepsAvailable = []
var actionsConsume = [1,2,1,1,1]

@export var btnAction1: Control
@export var btnAction2: Control
@export var btnAction3: Control
@export var actionsPerTurnText: Control
@export var movementsPerActionText: Control
 

func _ready():
	$AnimationPlayer.play("idle_right")
	StartTurn()

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
		health += 25
		if health > 100:
			health = 100
		
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
	
func StartActionPerTurn(id):
	if stepsAvailable[id] > 0:
		stepsAvailable[id] -= 1
		
	if id == 2:
		movementsPerActionText.text = str(stepsAvailable[2])
	
	if stepsAvailable[id] == 0:
		OnActionFinished()	
			
 
func MovePlayer(x, y):
	isMoving = true
	
	StartActionPerTurn(2)
	
	var direction = Vector2i.ZERO
	
	if(y > self.transform.origin.y && x == self.transform.origin.x):
		direction = Vector2i.DOWN
	elif (y < self.transform.origin.y && x == self.transform.origin.x):
		direction = Vector2i.UP
	elif (x > self.transform.origin.x && y == self.transform.origin.y):
		direction = Vector2i.RIGHT
	elif (x < self.transform.origin.x && y == self.transform.origin.y):
		direction = Vector2i.LEFT
	
	$AnimationPlayer.play("walk" + GetDirectionSuffix(direction))
	
	var targetPosition = position + direction * 128.0
	var tween = create_tween()
	
	tween.tween_property(self, "position", targetPosition, 0.5)
	
	await tween.finished
	
	isMoving = false
	$AnimationPlayer.play("idle" + GetDirectionSuffix(direction))
	
 
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
