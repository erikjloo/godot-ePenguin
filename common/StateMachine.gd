extends Node
class_name StateMachine

# Member variables
var current_state : int = 0
var previous_state : int = 0
onready var parent := get_parent()
var states : Dictionary

func _process(delta : float) -> void:
  if current_state:
    _state_logic(delta)
    var transition := _get_transition(delta)
    if transition:
      set_state(transition)

func _state_logic(_delta : float) -> void:
  pass

func _get_transition(_delta : float) -> int:
  return 0

func _enter_state(_new_state : int, _old_state : int) -> void:
  pass

func _exit_state(_old_state : int, _new_state : int) -> void:
  pass

func set_state(new_state : int) -> void:
  previous_state = current_state
  current_state = new_state

  if previous_state != 0:
    _exit_state(previous_state, new_state)
  if new_state != 0:
    _enter_state(new_state, previous_state)

func add_state(state_name : String) -> void:
  states[state_name] = states.size() + 1

func get_state(state : int) -> String:
  return states.keys()[state - 1]
