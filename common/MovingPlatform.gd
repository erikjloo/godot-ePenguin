extends Node2D
class_name MovingPlatform

# Member variables
const IDLE_DURATION : float = 1.0
const SHIFT_TRANS : int = Tween.TRANS_LINEAR
const SHIFT_EASE : int = Tween.EASE_IN_OUT

export var move_to : Vector2 = Vector2.DOWN * 192
export var speed : float = 300

onready var platform : KinematicBody2D = $Platform
onready var tween : Tween = $MoveTween
var follow : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  _init_tween()

func _physics_process(_delta : float) -> void:
  platform.position = platform.position.linear_interpolate(follow, 0.075)

func _init_tween() -> void: 
  var duration : float = move_to.length()/speed
  var return_duration : float = duration + IDLE_DURATION*2
  tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, \
                             duration, SHIFT_TRANS, SHIFT_EASE, IDLE_DURATION)
  tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, \
                             duration, SHIFT_TRANS, SHIFT_EASE, return_duration)
  tween.start()
