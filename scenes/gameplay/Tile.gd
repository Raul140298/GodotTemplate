extends Area2D

@export var player: Node2D
@export var gameController: Node
@export var guest: Node2D

var isFriendlyTile = false
var isHighLited = false

func _ready():
	isFriendlyTile = self.transform.origin.x < 512
	NoHoverTile()
	mouse_entered.connect(HoverTile)
	mouse_exited.connect(NoHoverTile)
	

func DamageTile(damage, initialTurn, turnsToDamage):
	if gameController.turn == (initialTurn + turnsToDamage):
		if guest != null:
			guest.TakeDamage(damage)


func HoverTile():
	if isFriendlyTile:
		if gameController.stepsAvailable[2] > 0 && distanceBetweenPlayer() <= 128  && distanceBetweenPlayer() > 0:
			isHighLited = true
			$Sprite2D.modulate = Color(1,1,1,1)
	else :
		if gameController.stepsAvailable[0] > 0 || gameController.stepsAvailable[1] > 0:
			isHighLited = true
			$Sprite2D.modulate = Color(1,1,1,1)


func NoHoverTile():
	$Sprite2D.modulate = Color(0.8,0.8,0.8,1)
	isHighLited = false


func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("Click") && isHighLited:
		NoHoverTile()
		if isFriendlyTile:
			gameController.MovePlayer(self.transform.origin.x, self.transform.origin.y)
		else :
			if gameController.stepsAvailable[0] > 0:
				gameController.StartActionPerTurn(0)
				DamageTile(10,gameController.turn,1)
			elif gameController.stepsAvailable[1] > 0:
				gameController.StartActionPerTurn(1)
				DamageTile(30,gameController.turn,1)


func distanceBetweenPlayer() -> float:
	return pow((pow((self.transform.origin.x - player.transform.origin.x),2) + pow((self.transform.origin.y - player.transform.origin.y),2)), (1.0/2.0))
