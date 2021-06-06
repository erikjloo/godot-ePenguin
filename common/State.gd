extends Node
class_name State

var fsm: StateMachine
var object: Object
var animations
var sound

func enter() -> void:
  """ Play sound and animations """
  return

func exit(next_state) -> void:
  fsm._change_to(next_state)

func input(event : InputEvent) -> InputEvent:
  """ Input logic """
  return event

func process(delta) -> void:
  """ State logic """
  return

func physics_process(delta):
  """ State logic """
  return
