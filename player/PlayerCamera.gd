extends Camera2D
class_name PlayerCamera

# Member variables
const LOOK_AHEAD : float = 0.2
const SHIFT_TRANS : int = Tween.TRANS_SINE
const SHIFT_EASE : int = Tween.EASE_OUT
const SHIFT_DURATION : float = 1.0

onready var previous_position : Vector2 = get_camera_position()
onready var tween : Tween = $ShiftTween
var direction : int = 0

func _process(_delta : float) -> void:
  _check_direction()
  previous_position = get_camera_position()

func _check_direction() -> void:
  var new_direction := int(sign(get_camera_position().x - previous_position.x))
  if new_direction != 0 and direction != new_direction:
    direction = new_direction
    var target_offset : float = get_viewport_rect().size.x * direction * LOOK_AHEAD
    tween.interpolate_property(self, "position:x", position.x, target_offset, \
                               SHIFT_DURATION, SHIFT_EASE, SHIFT_TRANS)
    tween.start()

func _on_grounded_updated(is_grounded : bool) -> void:
  # Disable vertical drag margin when the player is on the ground
  drag_margin_v_enabled = !is_grounded
