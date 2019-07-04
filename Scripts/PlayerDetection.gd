extends "res://Scripts/Character.gd"

const FOV_TOLERANCE = 20
const MAX_DETECTION_RANGE = 320
const RED = Color("#4bff0000")
const WHITE = Color("#ffffffcc")

onready var Player = get_tree().get_root().get_node("Level/Player")

var rotation_speed = 200
var player_seen = false
var player_in_range = false

func _ready():
	add_to_group("npc")


func _process(delta):
	player_in_range = Player_is_in_LOS()
	if Player_is_in_FOV_TOLERANCE() and player_in_range:
		$Torch.modulate = RED
		get_tree().call_group("SuspicionMeter", "player_seen",delta)
		player_seen = true
	else:
		player_seen  =false
		
		$Torch.modulate = WHITE
		
# Changes all angles to be 0-360
func normalize_rotation(cur_rotation):
	var new_rotation = cur_rotation
	while(new_rotation < 0):
		new_rotation += 360
	
	while(new_rotation > 360):
		new_rotation -= 360
	
	return new_rotation


func Player_is_in_FOV_TOLERANCE():
	var NPC_facing_direction = Vector2(1,0).rotated(global_rotation)
	var direction_to_Player = (Player.position - global_position).normalized()

	if abs(direction_to_Player.angle_to(NPC_facing_direction)) < deg2rad(FOV_TOLERANCE):
		return true
	else:
		return false


func Player_is_in_LOS():
	var space = get_world_2d().direct_space_state
	var LOS_obstacle = space.intersect_ray(global_position, Player.global_position, [self], collision_mask)

	if not LOS_obstacle:
		return false

	var distance_to_player = Player.global_position.distance_to(global_position)
	var Player_in_range = distance_to_player < MAX_DETECTION_RANGE
	
	if LOS_obstacle.collider == Player and Player_in_range:
		return true
	else:
		return false
	
	
func NightVision_mode():
	$Torch.visible = false
	pass

func DarkVision_mode():
	$Torch.visible = true
	pass