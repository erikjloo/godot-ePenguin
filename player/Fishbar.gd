extends Control
class_name FishBar

# Member variables
const PADDING : float = 1.05

export var fish : Texture = preload("res://common/fish/fish.png")
export var scale : Vector2 = Vector2(0.5, 0.5)
export (int, 0, 90) var rotation : int = 45
export var centered : bool = false
export var z_index : int = 1000
var max_value : int = 5
var sprites : Array = []

func update_maxfish(new_max_value : int) -> void:
  max_value = new_max_value

func update_fishbar(amount : int) -> void:
  if amount > sprites.size():
    for _i in range(amount - sprites.size()):
      _add_fish()
  elif amount < sprites.size():
    for _i in range(sprites.size() - amount):
      _remove_fish()

func _add_fish() -> void:
  if sprites.size() < max_value:
    var new_fish : Sprite = Sprite.new()
    new_fish.texture = fish
    new_fish.scale = scale
    new_fish.rotation = rotation
    new_fish.centered = centered
    new_fish.z_index = z_index
    new_fish.position.x = PADDING*sprites.size()*fish.get_size().x*scale.x
    add_child(new_fish)
    sprites.push_back(new_fish)

func _remove_fish() -> void:
  if !sprites.empty():
    sprites.pop_back().queue_free()
