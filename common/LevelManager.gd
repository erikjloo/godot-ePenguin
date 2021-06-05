extends Node

# Member variables
const SCENE_PATH : String = "res://levels/"
var current : String 

func change_scene(scene_name : String) -> void:
  # Waits for frame to end before calling new scene
  call_deferred("_deferred_change_scene", scene_name)

func _deferred_change_scene(scene_name : String) -> void:
  var root = get_tree().get_root()
  var current = root.get_child(root.get_child_count()-1)
  current.free()
  var new_scene = ResourceLoader.load(SCENE_PATH + scene_name + ".tscn").instance()
  get_tree().get_root().add_child(new_scene)
  get_tree().set_current_scene(new_scene)
