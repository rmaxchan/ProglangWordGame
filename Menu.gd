extends Control

@onready var high_score = $HighScoreLabel

func _ready():
	high_score.text = "Your High Score: %d" % get_high_score()

func get_high_score():
	if FileAccess.file_exists("user://hsproggers.bin"):
		var file = FileAccess.open("user://hsproggers.bin", FileAccess.READ)
		var high_score = file.get_32()
		file.close()
		return high_score
	return 0

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_how_2_button_pressed():
	get_tree().change_scene_to_file("res://how_to.tscn")
