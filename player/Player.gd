extends KinematicBody2D
class_name Player
""" ToDo:
Add sliding (reduced friction?) 
"""

# Member variables
const RockProjectile = preload("res://common/projectile/RockProjectile.tscn")

const RUN_SPEED : int = 900
const WALK_SPEED : int = 600
const ACCELERATION : int = 2000
const FRICTION : int = 1800
const MIN_JUMP_HEIGHT : int = 50
const MAX_JUMP_HEIGHT : int = 200
const JUMP_DURATION : float = 0.6
const TERMINAL_SPEED : int = 1000
const MAX_HEALTH : int = 100
const MIN_STAMINA : int = 50
const MAX_STAMINA : int = 100
const MAX_FISH_COUNT : int = 5
const DROP_THRU_BIT : int = 1
const SNAP : Vector2 = Vector2.DOWN * 32

onready var score : RichTextLabel = $"../HUD/Score"
onready var healthbar : HealthBar = $"../HUD/Health"
onready var stamina : ProgressBar = $"../HUD/Stamina"
onready var fishbar : FishBar = $"../HUD/FishBar"

onready var standing_collision : CollisionShape2D = $StandingShape
onready var crouching_collision : CollisionShape2D = $CrouchingShape
onready var standing_hitbox : CollisionShape2D = $Hitbox/StandingHitbox
onready var crouching_hitbox : CollisionShape2D = $Hitbox/CrouchingHitbox

onready var body : Node2D = $Body
onready var sprite : AnimatedSprite = $Body/Sprite
onready var actions : AnimatedSprite = $Body/Actions
onready var effects : AnimationPlayer = $Body/Effects
onready var camera : PlayerCamera = $PlayerCamera
onready var sound : PlayerSound = $PlayerSound
onready var state_machine : PlayerStateMachine = $PlayerStateMachine

onready var flutter_timer : Timer = $FlutterTimer
onready var coyote_timer : Timer = $CoyoteTimer
onready var invulnerability_timer : Timer = $InvulnerabilityTimer
onready var wall_raycasts : Node2D = $WallRayCasts

var gravity : float = 2*MAX_JUMP_HEIGHT/pow(JUMP_DURATION, 2)    # 1000
var max_jump_speed : float = -sqrt(2 * gravity * MAX_JUMP_HEIGHT) # 600
var min_jump_speed : float = -sqrt(2 * gravity * MIN_JUMP_HEIGHT)
var flutter_speed : float = 0.5*min_jump_speed
var health : int = MAX_HEALTH

var facing : int = 0
var direction : int = 0
var velocity : Vector2 = Vector2.ZERO
var acceleration : float
var is_grounded : bool = true
var is_running : bool = false
var is_crouch : bool = false
var can_run : bool = true
var score_value : int = 0
var fish_count : int = 0

signal grounded_updated(is_grounded)
signal killed()

func launch_rock():
  var rock = RockProjectile.instance()
  rock.position = global_position
  get_parent().add_child(rock)
  rock.launch(facing)

func collect_fish() -> void:
  fish_count += 1
  fishbar.update_fishbar(fish_count)

func apply_damage(amount : int) -> void:
  if invulnerability_timer.is_stopped():
    invulnerability_timer.start()
    _update_health(amount)
    effects.play("damage")
    effects.queue("flash")
    camera.get_node("ScreenShake").start()

func _handle_input() -> void:
  direction = - int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))

  if direction != 0:
    body.scale.x = direction
    facing = direction

func _apply_gravity(delta : float) -> void:
  velocity.y = min(velocity.y + gravity*delta, TERMINAL_SPEED)

func _apply_movement(delta : float) -> void:
  is_running = !is_crouch and can_run and Input.is_action_pressed("run")
  acceleration = ACCELERATION - FRICTION*int(Input.is_action_pressed("ui_down")) 
  var target_speed = direction * (RUN_SPEED if is_running else WALK_SPEED)
  velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
  velocity = move_and_slide_with_snap(velocity, SNAP*int(is_grounded), Vector2.UP)

#  var collision = move_and_collide(velocity * delta)
#  if collision:
#    collision.collider.velocity = velocity.length() * 0.5 * -collision.normal

  if is_grounded != is_on_floor(): # Check if grounded condition has changed
    is_grounded = is_on_floor()
    emit_signal("grounded_updated", is_grounded)

func _update_stamina() -> void:
  var increment : int = -1 if !is_grounded or state_machine.is_running() else 1
  stamina.value = clamp(stamina.value + increment, 0, MAX_STAMINA)
  if stamina.value <= 0:
    can_run = false
  elif stamina.value >= MIN_STAMINA: # Regen at least MIN_STAMINA before running
    can_run = true

func _update_health(amount : int) -> void:
  health = clamp(health + amount, 0, MAX_HEALTH)
  healthbar.update_healthbar(health, amount)
  if health <= 0:
    pass # Replace with call to level manager

func _slide() -> void:
  pass

func _jump(speed : float = max_jump_speed) -> void:
  coyote_timer.stop()                           # Prevent cheeky second jumps
  is_grounded = false                           # Unsnap player from ground
  velocity.y = speed                            # Impulse from jump
  emit_signal("grounded_updated", is_grounded)  # Update camera
  
func _flutter() -> void:
  velocity.y += flutter_speed # Impulse from flutter
  flutter_timer.start()       # Start the timer

func _on_crouch() -> void:
  standing_hitbox.disabled = true
  crouching_hitbox.disabled = false
  standing_collision.disabled = true
  crouching_collision.disabled = false
  is_crouch = true

func _on_stand() -> void:
  standing_hitbox.disabled = false
  crouching_hitbox.disabled = true
  while standing_collision.disabled and !state_machine.is_crouched():
    if can_stand():
      standing_collision.disabled = false
      crouching_collision.disabled = true
      is_crouch = false
    yield(get_tree(), "physics_frame")

func can_stand() -> bool:
  var query : Physics2DShapeQueryParameters = Physics2DShapeQueryParameters.new()
  query.set_shape(standing_collision.shape)
  query.transform = standing_collision.global_transform
  query.collision_layer = collision_mask
  var results : Array = get_world_2d().direct_space_state.intersect_shape(query)
  for i in range(results.size() - 1, -1, -1):
    var collider = results[i].collider
    var shape = results[i].shape
    if collider is CollisionObject2D and collider.is_shape_owner_one_way_collision_enabled(shape):
      results.remove(i)
    elif collider is TileMap:
      var tile_id = collider.get_cellv(results[i].metadata)
      if collider.tile_set.tile_get_shape_one_way(tile_id, 0):
        results.remove(i)
  return results.empty()

func _on_pulse_received() -> void:
  pass

func _on_dropped_through(_body : PhysicsBody2D) -> void:
  set_collision_mask_bit(DROP_THRU_BIT, true)

func _on_invulnerability_timeout() -> void:
  effects.play("[stop]")
