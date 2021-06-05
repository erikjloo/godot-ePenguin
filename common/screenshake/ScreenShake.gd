extends Node

# Member variables
const SHIFT_TRANS : int = Tween.TRANS_SINE
const SHIFT_EASE : int = Tween.EASE_OUT

onready var camera : Camera2D = get_parent()
onready var shake_tween : Tween = $ShakeTween
onready var frequency : Timer = $Frequency
onready var duration : Timer = $Duration
var amplitude : float = 0
var priority : int = 0

func start(new_duration : float = 0.2, new_frequency : float = 15.0, \
           new_amplitude : float = 16.0, new_priority : int = 0) -> void:
  if new_priority >= priority:
    amplitude = new_amplitude
    duration.wait_time = new_duration
    frequency.wait_time = 1 / float(new_frequency)
    duration.start()
    frequency.start()
    _new_shake()

func _new_shake() -> void:
  var rand : Vector2 = Vector2()
  rand.x = rand_range(-amplitude, amplitude)
  rand.y = rand_range(-amplitude, amplitude)
  shake_tween.interpolate_property(camera, "offset", camera.offset, rand, \
                                  frequency.wait_time, SHIFT_TRANS, SHIFT_EASE)
  shake_tween.start()

func _reset() -> void:
  shake_tween.interpolate_property(camera, "offset", camera.offset, Vector2(), \
                                  frequency.wait_time, SHIFT_TRANS, SHIFT_EASE)
  shake_tween.start()
  frequency.stop()
  priority = 0
