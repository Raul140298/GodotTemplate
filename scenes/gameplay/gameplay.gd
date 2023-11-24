extends Node

@export var player: Node2D


func _on_action_1_pressed():
	player.SelectAction(0)


func _on_action_2_pressed():
	player.SelectAction(1)


func _on_action_3_pressed():
	player.SelectAction(2)


func _on_finish_turn_pressed():
	player.FinishTurn()
