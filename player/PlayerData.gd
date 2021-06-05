extends Node

# Member variables:
const SAVE_PATH : String = "user://playerdata.save"

func save_player_data(score : int) -> void:
  if load_player_data() > score:
    return
  var file = File.new()
  file.open(SAVE_PATH, File.WRITE)
  file.store_line(to_json({highscore = score}))
  
func load_player_data() -> int:
  var file = File.new()
  if !file.file_exists(SAVE_PATH):
    return 0
  file.open(SAVE_PATH, File.READ)
  var data = parse_json(file.get_line())
  return data["highscore"]
