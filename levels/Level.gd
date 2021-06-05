extends Node
class_name Level

# Member variables
export var limit_left : int = 0
export var limit_top : int = -100000
export var limit_right : int = 100000
export var limit_bottom : int = 100000
export var zoom : Vector2 = Vector2.ONE

onready var parent = get_parent()

func _ready() -> void:
  var camera = parent.get_node("Player/PlayerCamera")
  camera.limit_left = limit_left
  camera.limit_top = limit_top
  camera.limit_right = limit_right
  camera.limit_bottom = limit_bottom
  camera.zoom = zoom
