extends Node

@onready var pause_menu = $"../PauseMenu"

var game_paused:bool = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		game_paused = !game_paused
		
	if game_paused == true:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()


func _on_return_pressed() -> void:
	game_paused = !game_paused


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_pause_button_pressed() -> void:
	game_paused = !game_paused
