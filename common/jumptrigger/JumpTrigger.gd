extends Area2D

func _on_body_entered(body : Node2D) -> void:
  if body.name == "Player": # Need to check because gdscript it not type-checked
    body.is_grounded = false
