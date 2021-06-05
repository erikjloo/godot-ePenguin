extends Control
class_name HealthBar

# Member variables
const FLASH_RATE : float = 0.05
const FLASH_COUNT : int = 4
const SHIFT_TRANS : int = Tween.TRANS_SINE
const SHIFT_EASE : int = Tween.EASE_IN_OUT

export var healthy_color : Color = Color.green
export var caution_color : Color = Color.yellow
export var danger_color : Color = Color.red
export var pulse_color : Color = Color.darkred
export var flash_color : Color = Color.orange

export (float, 0, 1, 0.05) var caution_zone : float = 0.5
export (float, 0, 1, 0.05) var danger_zone : float = 0.2
export var will_pulse : bool = true

onready var health_under : TextureProgress = $HealthUnder
onready var health_over : TextureProgress = $HealthOver
onready var update_tween : Tween = $UpdateTween
onready var pulse_tween : Tween = $PulseTween
onready var flash_tween : Tween = $FlashTween

signal pulse()

func update_maxhealth(max_health : int) -> void:
  health_over.max_value = max_health
  health_under.max_value = max_health

func update_healthbar(health : int, amount : int) -> void:
  health_over.value = health
  update_tween.interpolate_property(health_under, "value", health_under.value, \
                                    health, 0.4, SHIFT_TRANS, SHIFT_EASE)
  update_tween.start()
  _assign_color(health)
  if amount < 0:
    _flash_damage()

func _assign_color(health) -> void:
  if health <= 0:
    pulse_tween.set_active(false)
  elif health < health_over.max_value * danger_zone:
    if will_pulse and !pulse_tween.is_active():
      pulse_tween.interpolate_property(health_over, "tint_progress", pulse_color, \
                                       danger_color, 1.2, SHIFT_TRANS, SHIFT_EASE)
      pulse_tween.interpolate_callback(self, 0.0, "emit_signal", "pulse")
      pulse_tween.start()
    else:
      health_over.tint_progress = danger_color
  elif health < health_over.max_value * caution_zone:
    pulse_tween.set_active(false) 
    health_over.tint_progress = caution_color
  else:
    pulse_tween.set_active(false)
    health_over.tint_progress = healthy_color

func _flash_damage() -> void:
  for i in range(FLASH_COUNT * 2):
    var color : Color = health_over.tint_progress if i % 2 else flash_color
    var time : float = FLASH_RATE * i + FLASH_RATE
    flash_tween.interpolate_callback(health_over, time, "set", "tint_progress", color)
  flash_tween.start()
