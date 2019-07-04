extends TextureProgress

var suspicion = 0

export var suspicion_step = 100 #How much suspicion goes up every time we're seen
export var suspicion_dropoff = 0.25 # How fast suspicion falls


func _process(delta):
	suspicion -= suspicion_dropoff
	suspicion = clamp(suspicion, 0, max_value)	
	value = suspicion


func player_seen(delta):
	suspicion += suspicion_step * delta
	if suspicion >= max_value:
		get_tree().call_group("Alarm", "alarm_sounded")


func end_game():
	get_tree().change_scene("res://Scenes/GameOverScreen.tscn")