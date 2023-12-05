extends Area2D

@export var player: Node2D
@export var gameController: Node
@export var guest: Node2D

var isFriendlyTile = false
var isHighLited = false
var damageOnTheTileHistory = []

func _ready():
	isFriendlyTile = self.transform.origin.x < 512
	NoHoverTile()
	mouse_entered.connect(HoverTile)
	mouse_exited.connect(NoHoverTile)
	$Label.text = ""
	

func DamageTile(damage, initialTurn, turnsToDamage, type):
	if damageOnTheTileHistory.is_empty():
		gameController.turnChanged.connect(OnDamageTileSignal)
		
	damageOnTheTileHistory.append(DamageOnTheTile.new(damage, initialTurn + turnsToDamage, type))
	SetTileDamageText()

func OnDamageTileSignal():
	var damage = 0
	
	if guest != null:
		damage = guest.health
	
	for dmgTile in damageOnTheTileHistory:
		if gameController.turn == dmgTile.turnToTrigger:
			if guest != null:
				guest.TakeDamage(dmgTile.damage, dmgTile.type)
			dmgTile.shouldBeErased = true
	
	if guest != null:	
		damage -= guest.health
		if damage > 0:
			guest.Popup(str(damage), 36)
	
	var i = 0
	while i < damageOnTheTileHistory.size():
		var dmgTile = damageOnTheTileHistory[i]
		if dmgTile.shouldBeErased == true:
			damageOnTheTileHistory.erase(dmgTile)
		else:
			i += 1
		
	if damageOnTheTileHistory.is_empty():
		gameController.turnChanged.disconnect(OnDamageTileSignal)
		
	SetTileDamageText()


func HoverTile():
	if isFriendlyTile:
		if gameController.stepsAvailable[2] > 0 && distanceBetweenPlayer() <= 128  && distanceBetweenPlayer() > 0:
			isHighLited = true
			$Sprite2D.modulate = Color(1,1,1,1)
	else :
		if gameController.stepsAvailable[0] > 0 || gameController.stepsAvailable[1] > 0:
			isHighLited = true
			$Sprite2D.modulate = Color(1,1,1,1)


func GetMousePosition()-> Vector2:
	return get_global_mouse_position()


func NoHoverTile():
	$Sprite2D.modulate = Color(0.8,0.8,0.8,1)
	isHighLited = false


func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("Click") && isHighLited:
		NoHoverTile()
		if isFriendlyTile:
			gameController.MovePlayer(self)
		else :
			if gameController.stepsAvailable[0] > 0:
				gameController.StartActionPerTurn(0)
				DamageTile(10, gameController.turn, 2, "Fast")
			elif gameController.stepsAvailable[1] > 0:
				gameController.StartActionPerTurn(1)
				DamageTile(30, gameController.turn, 2, "Slow")


func SetTileDamageText():
	var damage = 0
	
	for d in damageOnTheTileHistory:
		damage += d.damage
	
	if damage <= 0:
		$Label.text = ""
	else:
		$Label.text = str(damage)


func distanceBetweenPlayer() -> float:
	return pow((pow((self.transform.origin.x - player.transform.origin.x),2) + pow((self.transform.origin.y - player.transform.origin.y),2)), (1.0/2.0))
