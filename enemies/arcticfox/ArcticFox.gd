extends KinematicBody2D

# Declare member variables here. Examples:
const JUMP_THRESHOLD : int = 30
const TERMINAL_SPEED : int = 1000
const SNAP : Vector2 = Vector2.DOWN * 32

export (int, -20, 0) var damage : int = -10
export (int, 100, 1000) var run_speed : int = 500
export (int, 100, 1000) var attack_speed : int = 600
export (int, 1000, 10000) var acceleration : int = 2000
export (int, 1000, 10000) var friction : int = 1800
export (int, 0, 200) var jump_height : int = 100
export (float, 0.1, 1.0) var jump_duration : float = 0.3
export (int, 0, 100) var max_health : int = 50

onready var healthbar : HealthBar = $HealthBar

onready var body : Node2D = $Body
onready var actions : AnimationPlayer = $Body/Actions
onready var effects : AnimationPlayer = $Body/Effects
onready var sound : AudioStreamPlayer2D = $EnemySound
onready var state_machine : EnemyStateMachine = $EnemyStateMachine

onready var attack_player : RayCast2D = $Body/AttackPlayer
onready var wall_detector : RayCast2D = $Body/WallDetector
onready var trap_detector : RayCast2D = $Body/TrapDetector
onready var cliff_detector : RayCast2D = $Body/CliffDetector
onready var chase_player : Area2D = $ChasePlayer
onready var attack : Area2D = $Attack

onready var chase_timer : Timer = $ChaseTimer
onready var jump_timer : Timer = $JumpTimer

onready var collision : CollisionShape2D = $Collision
onready var player : Player = get_tree().get_root().get_node("Main/Player")

var gravity : float = 2*jump_height/pow(jump_duration, 2)    # 1000
var jump_speed : float = -sqrt(2 * gravity * jump_height) # 600
var health : int = max_health

var facing : int = 0
var direction : int = 0
var velocity : Vector2 = Vector2.ZERO
var is_grounded : bool = true
var should_chase : bool = false
var can_chase : bool = false
var can_jump : bool = true

func _apply_gravity(delta : float) -> void:
  velocity.y = min(velocity.y + gravity*delta, TERMINAL_SPEED)

func _apply_velocity(delta : float) -> void:
  velocity.x = move_toward(velocity.x, direction*run_speed, acceleration * delta)
  velocity = move_and_slide_with_snap(velocity, SNAP*int(is_grounded), Vector2.UP)
  is_grounded = is_on_floor()

func _turn() -> void:
  direction *= -1
  body.scale.x = direction

func _chase() -> void:
  if chase_timer.is_stopped(): # Enemy AI should not react immediately
    direction = sign(player.position.x - position.x)
    body.scale.x = direction
    _jump()

func _jump() -> void:
  if player.position.y < position.y-JUMP_THRESHOLD and jump_timer.is_stopped():
    jump_timer.start()
    is_grounded = false
    velocity.y = jump_speed

func _attack() -> void:
  print("attack!")
  velocity = position.direction_to(player.position) * attack_speed

func _on_attack(body : Node2D):
  if body.name == "Player":
    body.apply_damage(damage)

func _stop() -> void:
  direction = 0

func _should_chase() -> bool:
  chase_timer.start()
  return should_chase

func _should_attack() -> bool:
  # attack_player set to detect 9th collision layer (player hitbox)
  return attack_player.is_colliding()

func _should_turn() -> bool:
  # wall_detector and cliff_detector set to detect 1st and 2nd collision layers
  return !cliff_detector.is_colliding() or wall_detector.is_colliding() or \
          trap_detector.is_colliding()

func _should_sleep() -> bool:
  return !should_chase

func _update_health(amount : int) -> void:
  health = clamp(health + amount, 0, max_health)
  healthbar.update_healthbar(health, amount)
  if health <= 0:
    queue_free()

func apply_damage(amount : int) -> void:
  _update_health(amount)
  effects.play("damage")

func _on_chase_player_entered(body : Node2D):
  if body.name == "Player":
    should_chase = true

func _on_chase_player_exited(body : Node2D):
  if body.name == "Player":
    should_chase = false




func _on_Attack(body):
  pass # Replace with function body.
