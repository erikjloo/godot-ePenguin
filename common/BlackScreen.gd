extends ColorRect

# Member variables
onready var animation_player : AnimationPlayer = $AnimationPlayer

func _on_unload_scene(delay : float = 0.5) -> void:
  animation_player.play("fade")

func _on_scene_loaded() -> void:
  animation_player.play_backwards("fade")
