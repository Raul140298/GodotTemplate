extends Area2D

@export var player: Node2D

var isFriendlyTile = false
var isHighLited = false

# Called when the node enters the scene tree for the first time.
func _ready():
	isFriendlyTile = self.transform.origin.x < 512
	NoHoverTile()
	mouse_entered.connect(HoverTile)
	mouse_exited.connect(NoHoverTile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func HoverTile():
	if isFriendlyTile:
		if player.stepsAvailable[2] > 0 && distanceBetweenPlayer() <= 128  && distanceBetweenPlayer() > 0:
			isHighLited = true
			$Sprite2D.modulate = Color(1,1,1,1)
	else :
		if player.stepsAvailable[0] > 0 || player.stepsAvailable[1] > 0:
			isHighLited = true
			$Sprite2D.modulate = Color(1,1,1,1)


func NoHoverTile():
	$Sprite2D.modulate = Color(0.8,0.8,0.8,1)
	isHighLited = false


func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("Click") && isHighLited:
		NoHoverTile()
		if isFriendlyTile:
			player.MovePlayer(self.transform.origin.x, self.transform.origin.y)
		else :
			if player.stepsAvailable[0] > 0:
				player.StartActionPerTurn(0)
			elif player.stepsAvailable[1] > 0:
				player.StartActionPerTurn(1)


func distanceBetweenPlayer() -> float:
	return pow((pow((self.transform.origin.x - player.transform.origin.x),2) + pow((self.transform.origin.y - player.transform.origin.y),2)), (1.0/2.0))
