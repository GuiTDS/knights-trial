extends Control

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass


func _on_restart_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
