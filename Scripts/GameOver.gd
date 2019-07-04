extends CanvasLayer



func _on_Try_Again_pressed():
	get_tree().change_scene("res://Scenes/Levels/SplashScreen.tscn")


func _on_Quit_pressed():
	get_tree().quit()