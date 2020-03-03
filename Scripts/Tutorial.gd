extends Node2D

var text 
var briefcase_used = false

func _ready():
	add_to_group("interface")
	text = {
		"0":
		  "Welcome recruit. Please move to the next objective marker. Use the W-A-S-D keys to move.",
		"1":
		  "You'll want to stay in the shadows, security cameras and guards will use search lights to spot you.",
		"2":
		  "Use a disguise to hide from the light. Touch the disguise in the top left of the screen.",
		"3":
		  "There's a briefcase ahead.  Pick it up by walking over it.",
		"4":
		  "Briefcases are optional objectives, grab them if you can but don't risk the operation.",
		"5":
		  "The main objective is to assassinate the target. Assassinate the target by standing close to them for a few seconds.",
		"6":
		  "Great work recruit! Proceed to the extraction point."
		
		}
	update_pointer_position(0)
	$TutorialGUI/Popup.show()
	$GUI/DisguiseContainer.visible = false
	



func update_pointer_position(number):
	var pointer = $ObjectivePointer
	var marker = $ObjectiveMarkers.get_child(number)
	$Tween.interpolate_property(pointer, "position", pointer.position, marker.position,
			0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	$AudioStreamPlayer.play()
	$TutorialGUI/AnimationPlayer.play("MessageTransition")
	$TutorialGUI/Popup/Label.text = text[str(number)]



func _on_ObjectiveMove_body_entered(body):
	update_pointer_position(1)

func _on_ObjectiveAlarm_body_entered(body):
	update_pointer_position(2)

func _on_ObjectiveBriefcase1_body_entered(body):
	$GUI/DisguiseContainer.visible = true
	update_pointer_position(3)
	
func use_box():
	if(!briefcase_used):
		briefcase_used = true
		update_pointer_position(3)

func _on_ObjectiveBriefcase2_body_entered(body):
	update_pointer_position(4)

func _on_ObjectiveTarget_body_entered(body):
	update_pointer_position(5)
	$Target.visible = true
	
func _on_ObjectiveTarget2_body_entered(body):
	pass
	
func target_killed():
	update_pointer_position(6)


func NightVision_mode():
	$TutorialGUI/Popup.hide()


func DarkVision_mode():
	$TutorialGUI/Popup.show()
	
	
	
	
	












