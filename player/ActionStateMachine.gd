extends StateMachine
class_name ActionStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  add_state("none")
  add_state("chew_gum")
  call_deferred("set_state", states.none)

func _get_transition(delta : float) -> int:
  match current_state:
    states.none:
      if Input.is_action_pressed("launch"):
        return states.none
  return states.none

func _enter_state(new_state : int, old_state : int) -> void:
  match new_state:
    states.none:
      parent.actions.play("none")
    states.chew_gum:
      parent.actions.play("chew_gum")
