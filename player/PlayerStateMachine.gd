extends StateMachine
class_name PlayerStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  add_state("idle")
  add_state("walk")
  add_state("run")
  add_state("crouch")
  add_state("crawl")
  add_state("jump")
  add_state("fly")
  add_state("fall")
  add_state("slide")
  add_state("dead")
  call_deferred("set_state", states.idle)

func _input(event : InputEvent) -> void:
  if event.is_action_pressed("ui_accept"):
    if Input.is_action_pressed("ui_down"):
      parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)  # Fall through platform
    elif parent.is_grounded or !parent.coyote_timer.is_stopped():
      parent._jump()
    elif parent.stamina.value and parent.flutter_timer.is_stopped():
      parent._flutter()
  if event.is_action_released("ui_accept") and parent.velocity.y < parent.min_jump_speed:
    parent.velocity.y = parent.min_jump_speed
  if event.is_action_pressed("launch"):
    parent.launch_rock()

func _state_logic(delta : float) -> void:
  parent._handle_input()
  parent._apply_gravity(delta)
  parent._apply_movement(delta)
  parent._update_stamina()

func _get_transition(_delta : float) -> int:
#      fall <--------> fly
#        \ ^.        ,^ /
#         \  \.    ,/  /
#          \   \  /   /
#           \  jump  /
#            \  |   /
#             \ |  /
#              \| V
#  idle/crouch/walk/crawl/run
  if [states.idle, states.walk, states.run, states.crouch, states.crawl, states.slide].has(current_state):
    if !parent.is_grounded and parent.velocity.y < 0: # idle/walk/run to jump
      return states.jump
    elif !parent.is_grounded and parent.velocity.y >= 0: # idle/walk/run to fall
      parent.coyote_timer.start()
      return states.fall
    elif !parent.direction: # Any state can go back to idle/walk/run/crouch/crawl
      var stand : bool = !Input.is_action_pressed("ui_down") and parent.can_stand()
      return states.idle if stand else states.crouch
    elif !parent.is_running:
      var stand : bool = !Input.is_action_pressed("ui_down") and parent.can_stand()      
      return states.walk if stand else states.crawl
    elif parent.is_running:
      return states.run if !Input.is_action_pressed("ui_down") else states.slide
  if [states.jump, states.fly, states.fall].has(current_state):
    if !parent.is_grounded and parent.velocity.y < 0: # jump/fall to fly
      return states.fly
    elif !parent.is_grounded and parent.velocity.y >= 0: # jump/fly to fall
      return states.fall
    elif !parent.direction: # Any state can go back to idle/walk/run/crouch/crawl
      var stand : bool = !Input.is_action_pressed("ui_down") and parent.can_stand()
      return states.idle if stand else states.crouch      
    elif !parent.is_running:
      var stand : bool = !Input.is_action_pressed("ui_down") and parent.can_stand()
      return states.walk if stand else states.crawl
    elif parent.is_running:
      return states.run if !Input.is_action_pressed("ui_down") else states.slide
  return 0

func _enter_state(new_state : int, old_state : int) -> void:
  var state_name : String = get_state(new_state)
  # Enter slide state properly (play transition animation)
  if old_state != states.slide and new_state == states.slide:
    print("enter slide animation")
  parent.sprite.play(state_name)
  parent.sound._play(state_name)
  # Enter crouch state properly (change collision shapes and hitboxes)
  if [states.crouch, states.crawl].has(new_state):
    if ![states.crouch, states.crawl, states.slide].has(old_state):
      parent._on_crouch()

func _exit_state(old_state : int, new_state : int) -> void:
  # Exit slide state properly (play transition animation)
  if old_state == states.slide and new_state != states.slide:
    print("exit slide animation")
  # Exit crouch state properly (change collision shapes and hitboxes)
  if [states.crouch, states.crawl].has(old_state):
    if ![states.crouch, states.crawl, states.slide].has(new_state):
      parent._on_stand()

func is_crouched() -> bool:
  return [states.crouch, states.crawl, states.slide].has(current_state)

func is_running() -> bool:
  return current_state == states.run
