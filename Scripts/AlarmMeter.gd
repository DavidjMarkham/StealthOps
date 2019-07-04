extends TextureProgress

var alarm = 0
var alarm_on = false

export var alarm_dropoff = 0.25 # How fast alarm falls


func _process(delta):
	alarm -= alarm_dropoff
	alarm = clamp(alarm, 0, max_value)	
	value = alarm
	if alarm <= 0 && alarm_on:
		alarm_on = false
		get_tree().call_group("Alarm", "alarm_ended")
	
	
func alarm_sounded():
	alarm_on = true
	alarm = max_value	
	value = alarm
	
func player_seen(delta):
	# Set alarm back to full if player is seen again while alarm is triggered
	if(alarm>0):
		alarm = max_value	
		value = alarm