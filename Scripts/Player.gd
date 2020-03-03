extends "res://Scripts/Character.gd"

export var disguises = 3 # How many disguises you start with
export var disguise_duration = 5 # How long a disguise can last
export var disguise_slowdown = 0.25

var motion =Vector2()
var vision_change_on_cooldown = false

var disguised = false
var velocity_multiplier = 1

const DARK = 0
const NIGHTVISION = 1

var vision_mode = 0
var health = 30
var sfx_hit
var joystick

onready var blood_splatter = load('res://Scenes/BloodSplatter.tscn')

func _ready():
	joystick = get_node("/root/Level/GUI/MarginContainer/Joystick")
	# Load sounds
	sfx_hit = load("res://SFX/Hit.ogg")	 
	sfx_hit.set_loop(false)
	
	Global.Player = self
	vision_mode = DARK
	$Timer.wait_time = disguise_duration
	update_disguise_display()
	reveal()


func _process(delta):	
	update_motion(delta)
	
	if disguised:
		rotation_degrees = 0
		$Label.rect_rotation = -rotation_degrees
		$Label.text = str($Timer.time_left).pad_decimals(2)
	else:
		move_and_slide(motion * velocity_multiplier)

func update_motion(delta):
	
	
	
	if Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
		motion.y = clamp((motion.y - SPEED), -MAX_SPEED, 0)
	elif Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_up"):
		motion.y = clamp((motion.y + SPEED), 0, MAX_SPEED)
	else:
		motion.y = lerp(motion.y, 0, FRICTION)
	
	if Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
		motion.x = clamp((motion.x - SPEED), -MAX_SPEED, 0)
	elif Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
		motion.x = clamp((motion.x + SPEED), 0, MAX_SPEED)
	else:
		motion.x = lerp(motion.x, 0, FRICTION)
		
	if(joystick.output.x != 0):
		motion.x = clamp((motion.x + SPEED * joystick.output.x *.5), -MAX_SPEED, MAX_SPEED)
		
	if(joystick.output.y != 0):
		motion.y = clamp((motion.y + SPEED * joystick.output.y * .5), -MAX_SPEED, MAX_SPEED)

	#rotation = Vector2(-1 * motion.y,motion.x).normalized().angle_to(Vector2(0,0))
	look_at(Vector2(position.x + motion.x,position.y + motion.y))

func _input(event):
	if Input.is_action_just_pressed("ui_vision_mode_change") and not vision_change_on_cooldown:
		cycle_vision_mode()
		vision_change_on_cooldown = true
		$VisionModeTimer.start()
	if Input.is_action_just_pressed("toggle_disguise"):
		toggle_disguise()

func cycle_vision_mode():
	if vision_mode == DARK:
		get_tree().call_group("interface", "NightVision_mode")
		vision_mode = NIGHTVISION
	elif vision_mode == NIGHTVISION:
		get_tree().call_group("interface", "DarkVision_mode")
		vision_mode = DARK 


func _on_VisionModeTimer_timeout():
	vision_change_on_cooldown = false


func toggle_disguise():
	if disguised:
		reveal()
	elif disguises >0:
		disguise()


func reveal():
	$Label.visible = false
	$Sprite.texture = load(Global.player_sprite)
	
	velocity_multiplier = 1
	
	disguised = false
	collision_layer = 1

func use_box():
	disguise()
	
func disguise():
	$Label.visible = true
	$Sprite.texture = load(Global.box_sprite)
	collision_layer = 16
	
	velocity_multiplier = disguise_slowdown
	$Timer.start()
	
	disguises -=1
	update_disguise_display()
	disguised = true

func update_disguise_display():
	get_tree().call_group("DisguiseDisplay", "update_disguises", disguises)


func collect_briefcase():
	var loot = Node.new()
	loot.set_name("briefcase")
	add_child(loot)
	get_tree().call_group("interface", "collect_loot")
	
func killed_target():
	pass

func player_hit():
	health -= 10
	var blood_pool = blood_splatter.instance()
	blood_pool.position = position
	get_parent().call_deferred("add_child",blood_pool)
	if(health == 0):		
		var t = Timer.new()
		t.set_wait_time(.25)
		t.set_one_shot(true)
		t.connect("timeout", self, "end_game")
		t.start()		
		self.add_child(t)
	
func end_game():
	get_tree().change_scene("res://Scenes/GameOverScreen.tscn")




