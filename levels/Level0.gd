extends Level
class_name Level0
  
func _on_Level1_entered(body : Node2D) -> void:
  if body.name == "Player": # Need to check because gdscript it not type-checked
    $"/root/Main".change_scene("Level1")
