extends Node


const SAVE_PATH="res://savegame.bin"

func saveGame():
	var file = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	var data:Dictionary={
		"playerHP":Game.playerHP,
		"Gold":Game.Gold
	}
	var jstr=JSON.stringify(data)
	file.store_line(jstr)

func loadGame():
	var file = FileAccess.open(SAVE_PATH,FileAccess.READ)
	if FileAccess.file_exists(SAVE_PATH):
		if not file.eof_reached():
			var current_line=JSON.parse_string(file.get_line())
			if current_line:
				Game.playerHP=int(current_line["playerHP"])
				Game.Gold=int(current_line["Gold"])
