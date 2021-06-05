extends KinematicBody2D

# Declare member variables here. Examples:
const RUN_SPEED : int = 600
const ACCELERATION : int = 2000
const FRICTION : int = 1800
const JUMP_HEIGHT : int = 200
const JUMP_DURATION : float = 0.6
const TERMINAL_SPEED : int = 1000
const MAX_HEALTH : int = 50
#const MIN_STAMINA : int = 50
#const MAX_STAMINA : int = 100
const SNAP : Vector2 = Vector2.DOWN * 32

onready var healthbar : HealthBar = $HealthBar

onready var body : Node2D = $Body
onready var actions : AnimationPlayer = $Body/Actions
onready var effects : AnimationPlayer = $Body/Effects
onready var attack_player : RayCast2D = $Body/AttackPlayer
onready var cliff_detector : RayCast2D = $Body/CliffDetector
onready var chase_player_left : RayCast2D = $ChasePlayer/ChasePlayerLeft
onready var chase_player_right : RayCast2D = $ChasePlayer/ChasePlayerRight
onready var sound : AudioStreamPlayer2D = $EnemySound
onready var state_machine : EnemyStateMachine = $EnemyStateMachine

onready var collision : CollisionShape2D = $StandingShape

var gravity : float = 2*JUMP_HEIGHT/pow(JUMP_DURATION, 2)    # 1000
var max_jump_speed : float = -sqrt(2 * gravity * JUMP_HEIGHT) # 600
var health : int = MAX_HEALTH

var facing : int = 0
var direction : int = 0
var velocity : Vector2 = Vector2.ZERO
var is_grounded : bool = true

func _apply_gravity(delta : float) -> void:
  velocity.y = min(velocity.y + gravity*delta, TERMINAL_SPEED)

func _apply_velocity(delta : float) -> void:
  velocity.x = move_toward(velocity.x, direction*RUN_SPEED, ACCELERATION * delta)
  velocity = move_and_slide_with_snap(velocity, SNAP*int(is_grounded), Vector2.UP)

func _turn() -> void:
  direction *= -1
  body.scale.x = direction

func _chase() -> void:
  # Tell enemy to chase player
  pass

func _attack() -> void:
  pass

func _stop() -> void:
  pass

func _should_turn() -> bool:
  # cliff_detector set to detect 1st and 2nd collision layers
  return is_on_floor() and not cliff_detector.is_colliding()

func _should_chase() -> bool:
  # chase_player set to detect 9th collision layer (player hitbox)
  return chase_player_left.is_colliding() or chase_player_right.is_colliding()

func _should_sleep() -> bool:
  return !_should_chase()

func _should_attack() -> bool:
  # attack_player set to detect 9th collision layer (player hitbox)
  return attack_player.is_colliding()

func _update_health(amount : int) -> void:
  health = clamp(health + amount, 0, MAX_HEALTH)
  healthbar.update_healthbar(health, amount)
  if health <= 0:
    queue_free()

func apply_damage(amount : int) -> void:
  _update_health(amount)
  effects.play("damage")
