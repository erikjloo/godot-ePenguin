extends AudioStreamPlayer2D
class_name PlayerSound

# Member variables
export var sounds : Dictionary

func _play(state_name : String) -> void:
  if !is_playing() and sounds.has(state_name):
    var current_sounds = sounds[state_name]
    stream = current_sounds[randi() % current_sounds.size()]
    pitch_scale = rand_range(0.8, 1.1) # Adds more oomph
    play()
