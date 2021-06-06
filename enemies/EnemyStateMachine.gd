extends StateMachine
class_name EnemyStateMachine

# Member variables


# Called when the node enters the scene tree for the first time.
func _ready():
  add_state("sleep")
  add_state("chase")
  add_state("attack")
  call_deferred("set_state", states.sleep)

func _state_logic(delta : float) -> void:
  parent._apply_gravity(delta)

  if current_state != states.attack and parent._should_turn():
    parent._turn()

  if current_state == states.chase:
    parent._chase()
  else:
    parent._stop()

  parent._apply_velocity(delta)

func _get_transition(_delta : float) -> int:
  match current_state:
    states.sleep:
      if parent._should_chase():
        return states.chase
    states.chase:
      if parent._should_sleep():
        return states.sleep
      elif parent._should_attack():
        return states.attack
    states.attack:
      return states.chase
#      if parent.is_on_floor():
#        return states.sleep
  return 0

func _enter_state(new_state : int, _old_state : int) -> void:
  var state_name : String = get_state(new_state)
  parent.actions.play(state_name)
  parent.sound._play(state_name)
  if new_state == states.attack:
    parent._attack()

func _exit_state(_old_state : int, _new_state : int) -> void:
  pass

