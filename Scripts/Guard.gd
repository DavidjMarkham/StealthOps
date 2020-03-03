extends "res://Scripts/PlayerDetection.gd"

const GUARD_ROTATE_SPEED = 300
const GUARD_ROTATE_SPEED_TARGET = 300
const HUNT_MOVE_MULTIPLIER = 2
const GUARD_SEEK_PATH_WAIT = .25

var motion = Vector2()
var possible_destinations = []
var path = []
var destination = Vector2()
var target_rotation = -1
var seeking_player = false
var player_in_sights = false
var time_till_next_shot = 2
var alert_exclamation
var alert_question
var go_after_player = false
var last_position = Vector2(0,0)
var time_on_wall = 0

export var walk_slowdown = 0.5
export var nav_stop_threshold = 5

onready var exclamation_alert = load('res://Scenes/ExclamationAlert.tscn')
onready var question_alert = load('res://Scenes/QuestionAlert.tscn')
onready var navigation = Global.navigation
onready var available_destinations = Global.destinations

# Load sounds
var sfx_gun_shot
var sfx_spotted
var sfx_alarm

func _ready():
	sfx_gun_shot = load("res://SFX/gun-shot.ogg")	 
	sfx_gun_shot.set_loop(false)
	
	sfx_spotted = load("res://SFX/Spotted.ogg")	 
	sfx_spotted.set_loop(false)
	
	sfx_alarm = load("res://SFX/Alarm.ogg")	 
	sfx_alarm.set_loop(false)
	
	
	possible_destinations = available_destinations.get_children()	
	
	alert_exclamation = exclamation_alert.instance()
	alert_exclamation.position = position
	alert_exclamation.visible = false
	get_parent().call_deferred("add_child",alert_exclamation)
	
	alert_question = question_alert.instance()
	alert_question.position = position
	alert_question.visible = false
	get_parent().call_deferred("add_child",alert_question)
		
	make_path()


func _process(delta):	
	alert_exclamation.position = position
	alert_question.position = position
	
	if(!player_seen):	
		if(!seeking_player):
			alert_exclamation.visible = false
			alert_question.visible = false
		navigate(delta)
		player_in_sights = false
	else:
		if(!alert_exclamation.visible && !alert_question.visible):
			$AudioStreamPlayer2D.stream = sfx_spotted
			$AudioStreamPlayer2D.play()
		if(!alert_exclamation.visible):			
			alert_question.visible = true		
		# Turn to look at player
		
		var target_rotation = normalize_rotation(rad2deg(Player.position.angle_to_point(position)))		
				
		if abs(normalize_rotation(rotation_degrees) - target_rotation) >= 5 && abs(normalize_rotation(rotation_degrees) - target_rotation) < 355:
			if (target_rotation>normalize_rotation(rotation_degrees) && target_rotation - normalize_rotation(rotation_degrees) < 180):
				rotation_degrees += GUARD_ROTATE_SPEED_TARGET * delta	
			else:
				rotation_degrees -= GUARD_ROTATE_SPEED_TARGET * delta	
		else:
			rotation_degrees = rad2deg(Player.position.angle_to_point(position))		
		
		#look_at(Player.position)
		if(alert_exclamation.visible):
			if(!player_in_sights):
				player_in_sights = true
				time_till_next_shot = randf()*1 + .25
			time_till_next_shot -= delta
			if(time_till_next_shot<=0):
				fire_shot()
				time_till_next_shot = randf()*1 + .25
		


func navigate(delta):
	var distance_to_destination = global_position.distance_to(path[0])
	destination = path[0]

	# Turn to look at next waypoint	
	#if(target_rotation == -1 && !is_on_wall()):		
	target_rotation = normalize_rotation(rad2deg(destination.angle_to_point(position)))				
	if abs(normalize_rotation(rotation_degrees) - target_rotation) >= 5 && abs(normalize_rotation(rotation_degrees) - target_rotation) < 355:
		if (target_rotation>normalize_rotation(rotation_degrees) && target_rotation - normalize_rotation(rotation_degrees) < 180):
			rotation_degrees += GUARD_ROTATE_SPEED * delta	
		else:
			rotation_degrees -= GUARD_ROTATE_SPEED * delta	
	else:
		rotation_degrees = rad2deg(destination.angle_to_point(position))

	#look_at(destination)
	
	if distance_to_destination > nav_stop_threshold:
		move(delta)
	else:
		update_path()
	
func fire_shot():	
	$AudioStreamPlayer2D.stream = sfx_gun_shot
	$AudioStreamPlayer2D.play()
	get_tree().call_group("Player", "player_hit")
	pass
	

func move(delta):
	last_position = global_position
	if(seeking_player):
		motion = (destination-global_position).normalized() * (MAX_SPEED * HUNT_MOVE_MULTIPLIER)
	else:
		motion = (destination-global_position).normalized() * (MAX_SPEED * walk_slowdown)
	
	#look_at(destination)
	
	if(global_position==last_position):
		if(is_on_wall()):		
			time_on_wall += delta
			if(time_on_wall) > 1000:	
				time_on_wall = 0
				make_path()
	else:
		time_on_wall = 0
	
	move_and_slide(motion)


func make_path():
	if(seeking_player && go_after_player):
		#go_after_player = false
		path = navigation.get_simple_path(global_position, Player.global_position, false)		
	else:
		randomize()
		var next_destination = possible_destinations[randi() % possible_destinations.size()]
		
		path = navigation.get_simple_path(global_position, next_destination.global_position, false)
		
		target_rotation = -1

func update_path():
	if path.size() == 1:
		if(!seeking_player):
			if $Timer.is_stopped():
				$Timer.start()
		else:
			make_path()
			if $Timer.is_stopped():
				$Timer.start()

	else:	
		path.remove(0)
		target_rotation = -1	
		
func alarm_sounded():
	if(!alert_exclamation.visible):
		$AudioStreamPlayer2D.stream = sfx_alarm
		$AudioStreamPlayer2D.play()
		alert_exclamation.visible = true
		alert_question.visible = false	
		seeking_player = true
		#$Timer.wait_time = .25
		#if $Timer.is_stopped():
		#	$Timer.start()
		go_after_player	= true
		make_path()
	
func alarm_ended():
	if(seeking_player):
		alert_exclamation.visible = false
		alert_question.visible = false
		seeking_player = false
		$Timer.wait_time = 3
		$Timer.start()	
		make_path()
	go_after_player = false
	


func _on_Timer_timeout():
	if(!seeking_player):
		make_path()
