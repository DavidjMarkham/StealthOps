extends ColorRect



func _on_Area2D_body_entered(body):
	if(visible):
		get_tree().change_scene("res://Scenes/VictoryScreen.tscn")
		

func target_killed():
	visible = true