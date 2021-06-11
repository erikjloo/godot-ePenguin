extends CenterContainer
class_name Options

# Member variables
export var audio_bus_name := "Master"

onready var _bus := AudioServer.get_bus_index(audio_bus_name)
onready var volume : HSlider = $Grid/Volume
onready var back_button : Button = $Grid/BackButton

func _on_redraw():
  volume.value = db2linear(AudioServer.get_bus_volume_db(_bus))

func _apply_changes() -> void:
  AudioServer.set_bus_volume_db(_bus, linear2db(volume.value))
