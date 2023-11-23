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
 

func _ready():
	$AnimationPlayer.play("idle_right")
	StartTurn()


func _process(delta):
	if Input.is_action_just_pressed("FinishTurn"):
		await get_tree().create_timer(2).timeout
		print()
		print("NEXT TURN==============================")
		StartTurn()
	
	if actionsPerTurn > 0:
		if Input.is_action_just_pressed("Action1"):
			ActionChosen(0)
		
		if Input.is_action_just_pressed("Action2"):
			ActionChosen(1)
			
		if Input.is_action_just_pressed("Action3"):
			ActionChosen(2)
		
	
func ActionChosen(id):
	if actionsPerTurn > 0 && actionsPerTurn <actionsConsume[actionsAvailable[id]]:
		return
	
	actionsPerTurn -= actionsConsume[actionsAvailable[id]]
	print("    You chosed ", actions[actionsAvailable[id]])
	print("=======================================")
	stepsAvailable[actionsAvailable[id]] += steps[actionsAvailable[id]]
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
	print(actions[actionsAvailable[0]], " ", actions[actionsAvailable[1]], " ", actions[actionsAvailable[2]])
	print("=======================================")


func StartTurn():
	actionsPerTurn = 2
	stepsAvailable = [0,0,0,0,0]
	RandomizeActions()
	
func StartActionPerTurn(id):
	if stepsAvailable[id] > 0:
		stepsAvailable[id] -= 1
	
	print(actions[id], " ", stepsAvailable[id])
	print("=======================================")
	
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
