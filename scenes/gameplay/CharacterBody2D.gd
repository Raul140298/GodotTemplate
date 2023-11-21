extends CharacterBody2D
 
var isMoving = false
var actionsPerTurn = 2
var health = 100
var guard = 0
var actionsList =[0,1,2,3,4]
var actions = ["ShootSlow", "ShootFast", "Movement", "Health", "Guard"]
var steps = [1,1,2,1,1]
var actionsAvailable = []
var stepsAvailable = []
var selected = [0,0,0,0,0]
 

func _ready():
	$AnimationPlayer.play("idle_right")
	StartTurn()


func _process(delta):
	#if actionsAvailable.has(0) && stepsAvailable[0] > 0:
		
	#if actionsAvailable.has(1) && stepsAvailable[1] > 0:
		
	if actionsAvailable.has(2) && stepsAvailable[2] > 0:
		if !isMoving:
			if Input.is_action_pressed("ui_right"):
				if self.position.x < -64:
					MovePlayer(Vector2i.RIGHT)
			elif Input.is_action_pressed("ui_left"):
				if self.position.x > -448:
					MovePlayer(Vector2i.LEFT)
			elif Input.is_action_pressed("ui_down"):
				if self.position.y < 256:
					MovePlayer(Vector2i.DOWN)
			elif Input.is_action_pressed("ui_up"):
				if self.position.y > -256:
					MovePlayer(Vector2i.UP)
	
	if actionsAvailable.has(3) && stepsAvailable[3] > 0:
		if Input.is_action_pressed("ui_select"):
			StartActionPerTurn(3)
			health += 25
			if health > 100:
				health = 100
		
	#if actionsAvailable.has(4) && stepsAvailable[4] > 0:

func StartTurn():
	actionsPerTurn = 2
	var aux = actionsList
	aux.shuffle()
	actionsAvailable = aux.slice(0,3) #Arreglo de 3 ids desordenados
	stepsAvailable = [0,0,0,0,0]
	selected = [0,0,0,0,0]
	
	for i in range(3):
		stepsAvailable[actionsAvailable[i]] = steps[actionsAvailable[i]]
		print(actions[actionsAvailable[i]], " ", stepsAvailable[actionsAvailable[i]])
	
	print("=======================================")
	
func StartActionPerTurn(id):
	if stepsAvailable[id] == 0:
		return
	
	if stepsAvailable[id] == steps[id]:
		actionsPerTurn -= 1
		selected[id] = 1
		
		if actionsPerTurn == 0:
			actionsAvailable = []
			for i in range(5):
				if selected[i] == 1:
					actionsAvailable.append(i)
				else:
					stepsAvailable[i] = 0
				
	if stepsAvailable[id] > 0:
		stepsAvailable[id] -= 1
		if stepsAvailable[id] == 0:
			actionsAvailable.erase(id)
	
	print("ActionsLeft: ", actionsPerTurn)
	print(actions[id], " ", stepsAvailable[id])
	print("=======================================")
	
	var aux = 0
	for i in range(5):
		aux += stepsAvailable[i]
		
	if aux == 0:
		await get_tree().create_timer(1).timeout
		StartTurn()
 
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
