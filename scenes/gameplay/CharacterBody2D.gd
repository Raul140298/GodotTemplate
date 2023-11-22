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
		
	if stepsAvailable[2] > 0:
		if !isMoving:
			if Input.is_action_just_pressed("ui_right"):
				if self.position.x < -64:
					MovePlayer(Vector2i.RIGHT)
			elif Input.is_action_just_pressed("ui_left"):
				if self.position.x > -448:
					MovePlayer(Vector2i.LEFT)
			elif Input.is_action_just_pressed("ui_down"):
				if self.position.y < 256:
					MovePlayer(Vector2i.DOWN)
			elif Input.is_action_just_pressed("ui_up"):
				if self.position.y > -256:
					MovePlayer(Vector2i.UP)
	
	
func ActionChosen(id):
	actionsPerTurn -= 1
	print("    You chosed ", actions[actionsAvailable[id]])
	print("=======================================")
	stepsAvailable[actionsAvailable[id]] += steps[actionsAvailable[id]]
	
	InstantAction(actionsAvailable[id])
	
	if actionsPerTurn > 0:
		RandomizeActions()
		
func InstantAction(id):
	if id == 0 && stepsAvailable[0] > 0:
		print("Shoot fast Action")
		print("=======================================")	
		StartActionPerTurn(0)
		
	if id == 1 && stepsAvailable[1] > 0:
		print("Shoot slow Action")
		print("=======================================")	
		StartActionPerTurn(1)

	if id == 3 && stepsAvailable[3] > 0:
		print("Health Action")
		print("=======================================")	
		StartActionPerTurn(3)
		health += 25
		if health > 100:
			health = 100
		
	if id == 4 && stepsAvailable[4] > 0:
		print("Guard Action")
		print("=======================================")	
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
	
 
func MovePlayer(direction):
	StartActionPerTurn(2)
	
	isMoving = true
	
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
