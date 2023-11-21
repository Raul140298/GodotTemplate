extends CharacterBody2D

var is_moving = false

func _process(delta):
	if is_moving == false:
		$AnimationTree.get("parameters/playback").travel("Idle")
		
		if Input.is_action_pressed("ui_right"):
			if self.position.x < -64:
				move_player(Vector2(1, 0))
		elif Input.is_action_pressed("ui_left"):
			if self.position.x > -448:
				move_player(Vector2(-1, 0))
		elif Input.is_action_pressed("ui_down"):
			if self.position.y < 256:
				move_player(Vector2(0, 1))
		elif Input.is_action_pressed("ui_up"):
			if self.position.y > -256:
				move_player(Vector2(0, -1))

func move_player(direction):
	is_moving = true
	
	$AnimationTree.get("parameters/playback").travel("Walk")
	
	$AnimationTree.set("parameters/Walk/blend_position", direction)
	
	var target_position = position + direction * 128
	var tween = create_tween()
	
	tween.tween_property(self, "position", target_position, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	$AnimationTree.set("parameters/Idle/blend_position", direction)
	
	is_moving = false
