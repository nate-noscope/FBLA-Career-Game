extends Node2D

const TYPING_SPEED = 1

var animations := ["Start", "Earthquake", "Earthquake In City", "Economic Downturn"]
var texts := ["It is a beautiful, sunny day in Los Angeles, our nation's second-largest city.",
"But a high-magnitude earthquake interrupts the quiet sunset, due in part to increased meltwaters from glaciers due to global warming.",
"The earthquake causes inconcievable damage in the city and its citizens begin to panic.",
"Economic downturn ensues, and the stock market becomes highly volatile.",
"How will YOU choose to navigate the chaos of the earthquake?"
]
var current := 0
var last := 3
var current_char := 0


func _ready() -> void:
	$AnimatedSprite2D.play(animations[0])
	$Panel/AnimationPlayer.play("next_bounce")

func _process(_delta: float) -> void:
	if !$AnimatedSprite2D.is_playing():
		$Panel/AnimationPlayer.play("next_bounce")
	else:
		$Panel/AnimationPlayer.stop()
	if Input.is_action_just_pressed("click"):
		if current == last:
			get_tree().change_scene_to_file("res://menu_screen.tscn")
			return
		$AnimatedSprite2D.play(animations[current + 1])
		$Panel/Label.text = ""
		current += 1
		current_char = 0
	if $Panel/Label.text != texts[current]:
		for i in range(TYPING_SPEED):
			if texts[current].length() > current_char:
				$Panel/Label.text += texts[current][current_char]
			current_char += 1
