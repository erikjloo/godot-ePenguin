extends Area2D

func _on_player_entered(body : Node2D) -> void:
  if body.name == "Player" and body.fish_count < body.MAX_FISH_COUNT:
    $Audio.play()
    body.collect_fish()

func _on_audio_finished() -> void:
  queue_free()
