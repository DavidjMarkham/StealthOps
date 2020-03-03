extends "res://Scripts/PlayerDetection.gd"

onready var TweenNode = get_node("Tween")

const CAMERA_ROTATE_LEFT = 0
const CAMERA_ROTATE_PAUSE_LEFT  = 1
const CAMERA_ROTATE_RIGHT = 2
const CAMERA_ROTATE_PAUSE_RIGHT = 3
const CAMERA_MIN_ROTATION = -45
const CAMERA_MAX_ROTATION = 45
const CAMERA_SPEED = 25.0
const CAMERA_SPEED_TARGET = 3.0
const CAMERA_WAIT_TIME = .5
var alert_exclamation
var alert_question
onready var exclamation_alert = load('res://Scenes/ExclamationAlert.tscn')
onready var question_alert = load('res://Scenes/QuestionAlert.tscn')

var wait_time_left = 0 
var state = 0
var seeking_player = false

func _ready():
	alert_exclamation = exclamation_alert.instance()
	alert_exclamation.position = global_position
	alert_exclamation.visible = false
	get_parent().get_parent().call_deferred("add_child",alert_exclamation)
	
	alert_question = question_alert.instance()
	alert_question.position = global_position
	alert_question.visible = false
	get_parent().get_parent().call_deferred("add_child",alert_question)

func _process(delta):
	if Player_is_in_FOV_TOLERANCE() and Player_is_in_LOS():
		if(!alert_exclamation.visible):
			alert_question.visible = true
		$Torch.modulate = RED
		get_tree().call_group("SuspicionMeter", "player_seen",delta)
		# Turn to look at player
		var target_rotation = rad2deg(get_angle_to(Player.position))		
		rotation_degrees = clamp(rotation_degrees - (rotation_degrees - target_rotation) * CAMERA_SPEED_TARGET * delta,CAMERA_MIN_ROTATION,CAMERA_MAX_ROTATION)		
	else:
		alert_question.visible = false
		animate_camera(delta)
		$Torch.modulate = WHITE
		
func animate_camera(delta):
	# Pan camera left and right, pausing at left and right sides
	var target_rotation = rotation_degrees
	if(state == CAMERA_ROTATE_LEFT):
		target_rotation = CAMERA_MIN_ROTATION		
		rotation_degrees = rotation_degrees - CAMERA_SPEED * delta
		
		if(rotation_degrees <= CAMERA_MIN_ROTATION):			
			state = CAMERA_ROTATE_PAUSE_LEFT
			wait_time_left = CAMERA_WAIT_TIME
		rotation_degrees = clamp(rotation_degrees,CAMERA_MIN_ROTATION,CAMERA_MAX_ROTATION)		
		
			
	elif(state == CAMERA_ROTATE_RIGHT):
		target_rotation = CAMERA_MAX_ROTATION
		rotation_degrees = rotation_degrees + CAMERA_SPEED * delta
		
		if(rotation_degrees >= CAMERA_MAX_ROTATION):
			state = CAMERA_ROTATE_PAUSE_RIGHT
			wait_time_left = CAMERA_WAIT_TIME
		rotation_degrees = clamp(rotation_degrees,CAMERA_MIN_ROTATION,CAMERA_MAX_ROTATION)		
	elif(state == CAMERA_ROTATE_PAUSE_LEFT):		
		# Pause in position until timer runs out
		wait_time_left -= delta  
		if(wait_time_left <= 0):
			wait_time_left = 0
			state = CAMERA_ROTATE_RIGHT
	elif(state == CAMERA_ROTATE_PAUSE_RIGHT):		
		# Pause in position until timer runs out
		wait_time_left -= delta  
		if(wait_time_left <= 0):
			wait_time_left = 0
			state = CAMERA_ROTATE_LEFT
			
func alarm_sounded():	
	alert_exclamation.visible = true
	alert_question.visible = false
	seeking_player = true
	
	
func alarm_ended():
	alert_exclamation.visible = false
	alert_question.visible = false
	seeking_player = false