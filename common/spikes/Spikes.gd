extends Area2D

# Member variables
export (int, -20, 0) var damage : int = -10

func _on_body_entered(body : Node2D) -> void:
  if body.name == "Player":
    body.apply_damage(damage)
