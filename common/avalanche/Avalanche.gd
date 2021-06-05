extends Area2D

# Member variables
const SHIFT_TRANS : int = Tween.TRANS_LINEAR
const SHIFT_EASE : int = Tween.EASE_IN_OUT

export (int, -20, 0) var damage : int = -20
export (float, 0, 1) var duration : float = 0.4

onready var trigger : CollisionShape2D = $Trigger
onready var audio : AudioStreamPlayer2D = $Audio
onready var animation : AnimatedSprite = $SnowBall/Animation
onready var collision : CollisionShape2D = $SnowBall/Collision
onready var tween : Tween = $SnowBall/Tween

func _on_player_entered(body : Node2D) -> void:
  if body.name == "Player":
    trigger.queue_free()
    audio.play()
    body.camera.get_node("ScreenShake").start(duration)
    animation.play("Avalance")
    tween.interpolate_property(collision, "position:y", collision.position.y, \
                    collision.position.y+400, duration, SHIFT_TRANS, SHIFT_EASE)
    tween.start()

func _on_player_buried(body : Node2D) -> void:
  if body.name == "Player":
    body.apply_damage(damage)

func _on_animation_finished() -> void:
  collision.queue_free()
  tween.queue_free()
