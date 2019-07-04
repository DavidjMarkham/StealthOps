extends CanvasLayer



func _on_TutorialButton_pressed():
	get_tree().change_scene("res://Scenes/Levels/Tutorial.tscn")

func _on_Level1Button_pressed():
	get_tree().change_scene("res://Scenes/Levels/Level1.tscn")
	
func _on_Level2Button_pressed():
	get_tree().change_scene("res://Scenes/Levels/Level2.tscn")

func _on_Level3Button_pressed():
	get_tree().change_scene("res://Scenes/Levels/Level3.tscn")

func _on_Level4Button_pressed():
	get_tree().change_scene("res://Scenes/Levels/Level4.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()







