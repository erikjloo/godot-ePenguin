extends KinematicBody2D
class_name RockProjectile

# Member variables
const GRAVITY : int = 1000
const THROW_VELOCITY : Vector2 = Vector2(8000, -400)
const ENERGY_LOSS : float = 0.5

export (int, -20, 0) var damage : int = -10
var velocity : Vector2 = Vector2.ZERO

#signal entity_damaged(entity)

func launch(direction : int) -> void:
#  var temp = global_transform
#  var scene = get_tree().current_scene
#  get_parent().remove_child(self)
#  scene.add_child(self)
#  global_transform = temp
  velocity = THROW_VELOCITY * Vector2(direction, 1)
#  set_physics_process(true)

# Called when the node enters the scene tree for the first time.
#func _ready() ->void:
#  set_physics_process(false)

func _physics_process(delta : float) -> void:
  velocity.y += GRAVITY*delta
  var collision := move_and_collide(velocity * delta)
  if collision != null:
    _on_impact(collision.normal)

func _on_impact(normal : Vector2) -> void:
  velocity = velocity.bounce(normal)*(1-ENERGY_LOSS)

func _on_hitbox_entered(area : Area2D) -> void:
  # damage area is set to detect 10th collision layer (enemy hitbox)
  if area is Hitbox:
    area.entity.apply_damage(damage)
