extends "res://Scripts/Character.gd"

const GUARD_ROTATE_SPEED = 300
const GUARD_ROTATE_SPEED_TARGET = 3.0
const HUNT_MOVE_MULTIPLIER = 1

var motion = Vector2()
var possible_destinations = []
var path = []
var destination = Vector2()
var target_rotation = -1
var seeking_player = false
var player_in_sights = false
var time_till_next_shot = 2
var sfx_hit
var target_capture_progress
var player_in_range = false

export var walk_slowdown = 0.5
export var nav_stop_threshold = 5

onready var navigation = Global.navigation
onready var available_destinations = Global.destinations
onready var blood_splatter = load('res://Scenes/BloodSplatter.tscn')
onready var target_capture = load('res://Scenes/TargetCapture.tscn')

func _ready():
	target_capture_progress = target_capture.instance()
	get_node("/root").add_child(target_capture_progress)
	# Load sounds
	sfx_hit = load("res://SFX/Hit.ogg")	 
	sfx_hit.set_loop(false)
	possible_destinations = available_destinations.get_children()
	make_path()


func _process(delta):	
	target_capture_progress.position = position
	if(player_in_range):
		target_capture_progress.get_node("TextureProgress").value = float(target_capture_progress.get_node("TextureProgress").value) + delta * 500.0
		if(target_capture_progress.get_node("TextureProgress").value>=1000):
			owner.find_node("AudioStreamPlayer").stream = sfx_hit
			owner.find_node("AudioStreamPlayer").play(0)	
			var blood_pool = blood_splatter.instance()
			blood_pool.position = position
			get_node("/root").add_child(blood_pool)
			Global.Player.killed_target()			
			get_tree().call_group("TargetNotifier", "target_killed")			
			queue_free()			
			target_capture_progress.queue_free()
	navigate(delta)
		


func navigate(delta):
	var distance_to_destination = global_position.distance_to(path[0])
	destination = path[0]

	# Turn to look at next waypoint	
	if(target_rotation == -1 && !is_on_wall()):		
		target_rotation = normalize_rotation(rad2deg(PI + global_position.angle_to_point(destination)))				
	if abs(normalize_rotation(rotation_degrees) - target_rotation) >= 5 && abs(normalize_rotation(rotation_degrees) - target_rotation) < 355:
		if (target_rotation>normalize_rotation(rotation_degrees) && target_rotation - normalize_rotation(rotation_degrees) < 180):
			rotation_degrees += GUARD_ROTATE_SPEED * delta	
		else:
			rotation_degrees -= GUARD_ROTATE_SPEED * delta	
	else:
		rotation_degrees = rad2deg(PI + global_position.angle_to_point(destination))
	
	#look_at(destination)
	
	if distance_to_destination > nav_stop_threshold:
		move(delta)
	else:
		update_path()

# Changes all angles to be 0-360
func normalize_rotation(cur_rotation):
	var new_rotation = cur_rotation
	while(new_rotation < 0):
		new_rotation += 360
	
	while(new_rotation > 360):
		new_rotation -= 360
	
	return new_rotation

func move(delta):
	motion = (destination-global_position).normalized() * (MAX_SPEED * walk_slowdown)
		
	#look_at(destination)
	
	#if is_on_wall():
	#	make_path()
	
	move_and_slide(motion)


func make_path():
	randomize()
	var next_destination = possible_destinations[randi() % possible_destinations.size()]
	
	path = navigation.get_simple_path(global_position, next_destination.global_position, false)

	target_rotation = -1

func update_path():
	if path.size() == 1:
		if $Timer.is_stopped():
			$Timer.start()

	else:	
		path.remove(0)
		target_rotation = -1	
		
func _on_Timer_timeout():
	make_path()


func _on_AssasinateArea_body_entered(body):	
	player_in_range = true	

func _on_AssasinateArea_body_exited(body):
	player_in_range = false
	target_capture_progress.get_node("TextureProgress").value = 0
