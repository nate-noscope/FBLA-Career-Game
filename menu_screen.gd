extends Node2D


var careers := ["STOCK BROKER", "NURSE PRACTITIONER", "LAWYER"]
var current := 0

func _ready() -> void:
	$TextureButton2.flip_v = true
	$ColorRect.show()
	$AnimationPlayer.play("fade_from_black")


func _on_texture_button_pressed() -> void:
	print("pressed")
	current += 1
	if current == 3:
		current = 0
	$Label/Label2.text = careers[current]


func _on_texture_button_2_pressed() -> void:
	current -= 1
	if current == -1:
		current = 2
	$Label/Label2.text = careers[current]


func _on_button_pressed() -> void:
	$AnimationPlayer.play("fade_to_black")
	await get_tree().create_timer(1.0).timeout
	match current:
		0:
			get_tree().change_scene_to_file("res://stocks_game.tscn")
		1:
			get_tree().change_scene_to_file("res://nurse_game.tscn")
		2:
			get_tree().change_scene_to_file("res://lawyer_game.tscn")
