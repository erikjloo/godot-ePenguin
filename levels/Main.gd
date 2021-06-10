extends Node

# Member variables
const SCENE_PATH : String = "res://levels/"
const STATEFULL : String = "Statefull" # Not yet used
const SAVE_DEPTH : int = 14 # Not yet used

onready var player : Player = $Player

var scene_states : Dictionary = {}
var current_level : String = "Level0"
var current_scene : Level

signal unload_scene(delay)
signal scene_loaded()

func _input(event : InputEvent) -> void:
  if event.is_action_pressed("ui_cancel"):
    get_tree().paused = !get_tree().paused # toggle pause status

func _ready() -> void:
  pause_mode = PAUSE_MODE_STOP
  connect("scene_loaded", $HUD/BlackScreen, "_on_scene_loaded")
  connect("unload_scene", $HUD/BlackScreen, "on_unload_scene")
  _load_scene("Level1")

func change_scene(new_level : String, delay : float = 0.5) -> void:
  # Should i check if the current_scene does not exist?
  # How will i handle the game loading from a main menu
  _unload_scene()
  _load_scene(new_level)

func _unload_scene() -> void:
  # Remove the current_scene from main and unload it
#  _save_state()
  emit_signal("unload_scene")
  remove_child(current_scene)
  current_scene.call_deferred("free")

func _load_scene(new_level : String) -> void:
  # Load the new scene and add it as a child of main
  current_scene = load(SCENE_PATH + new_level + ".tscn").instance()
  add_child(current_scene)
  # Place player in the correct position
  var new_position = current_level + "_" + new_level
  player.position = current_scene.get_node(new_position).position
  # Update current_level
  current_level = new_level
  emit_signal("scene_loaded")

func _save_state(deep : bool = false) -> void:
  scene_states[current_level] = []

  for x in current_scene.get_children():
    if x.is_in_group(STATEFULL):
      var begin = 0 if deep else SAVE_DEPTH
      var end = x.get_property_list().size()
      for i in range(begin, end):
        var new_key = x.get_property_list()[i]["name"]
        var new_val = x.get(new_key)
        scene_states[current_level].append({new_key:new_val})

func _load_state(new_level : String, deep : bool = false) -> void:
  if !scene_states.has(new_level):
    return

  var curr_dict = scene_states[new_level]
  var ignore = 0 if deep else SAVE_DEPTH
  var count = 0

  for x in current_scene.get_children():
    if x.is_in_group(STATEFULL):
      var prop_range = x.get_property_list().size() - ignore
      for _val in range(0, prop_range):
        x.set(curr_dict[count].keys()[0], curr_dict[count].values()[0])
        count+=1
