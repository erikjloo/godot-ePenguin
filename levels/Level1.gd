extends Level
class_name Level1

func _on_Level0_entered(body : Node2D) -> void:
  if body.name == "Player": # Need to check because gdscript it not type-checked
    $"/root/Main".change_scene("Level0")

func _on_Level2_entered(body : Node2D) -> void:
  if body.name == "Player": # Need to check because gdscript it not type-checked
    $"/root/Main".change_scene("Level2")
