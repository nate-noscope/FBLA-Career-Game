extends Node2D

@onready var FBLALogo = $"FBLA-logo"
@onready var Layer2 = $Layer2


func _ready() -> void:
	FBLALogo.play("default")


func _on_fbl_alogo_frame_changed() -> void:
	if FBLALogo.frame == 18:
		FBLALogo.stop()
		FBLALogo.frame = 19
		$Timer.start()

func _on_timer_timeout() -> void:
	$Layer2.visible = true
	$Timer2.start()

func _process(delta: float) -> void:
	if Layer2.visible:
		$Layer2/Node2D.modulate.a += 2 * delta


func _on_timer_2_timeout() -> void:
	$BlackFade/AnimationPlayer.play("fade_to_black")
	await $BlackFade/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://menu_screen.tscn")
