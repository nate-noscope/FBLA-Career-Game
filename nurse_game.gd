extends Node2D

enum Tools{NONE, PLASTER, PRESCRIPTION, IV_FLUID}
const MAX_ARM_CLICKS = 3
const LAST_PATIENT = 1

var time := 0.0
var current_patient = 1
var isToolsOut := false
var isTicking := false
var currentTool := Tools.NONE
var castOn := false
var ivOn := false
var medicinePrescribed := false
var armClicks := 0


func _ready() -> void:
	DialogueManager.show_dialogue_balloon(load("res://nurse_game_intro.dialogue"), "start")
	$BlackFade/AnimationPlayer.play("fade_from_black")
	$TextureButton.set_position(Vector2(-194, 61))

func _process(delta: float) -> void:
	if isTicking:
		time += delta
		$Time/TimeLabel.text = str(snapped(120.0 - time, 0.1))

func nextPatient():
	$BlackFade/AnimationPlayer.play("fade_to_black")
	await get_tree().create_timer(1.0).timeout
	$BlackFade/AnimationPlayer.play("fade_from_black")

func endGame():
	pass

func _on_texture_button_pressed() -> void:
	if isToolsOut:
		$TextureButton/AnimationPlayer.play("slide_left")
		isToolsOut = false
	else:
		$TextureButton/AnimationPlayer.play("slide_right")
		isToolsOut = true

func _on_arm_pressed() -> void:
	print("hello")
	if currentTool == Tools.PLASTER:
		armClicks += 1
		if armClicks >= MAX_ARM_CLICKS:
			castOn = true
			$Patient.play("idle_cast")
			$ToolUsePopup.show()
			$ToolUsePopup.text = "Cast applied!"
			$ToolUsePopup/AnimationPlayer.play("popup_fade")

func _on_left_hand_pressed() -> void:
	print("hello")
	if currentTool == Tools.IV_FLUID and !ivOn:
		ivOn = true
		print("yup")
		$ToolUsePopup.show()
		$ToolUsePopup.text = "IV added!"
		$ToolUsePopup/AnimationPlayer.play("popup_fade")


func _on_plaster_roll_pressed() -> void:
	currentTool = Tools.PLASTER
	$Tool/Sprite2D.texture = load("res://plaster-roll-icon.png")


func _on_prescription_pressed() -> void:
	currentTool = Tools.PRESCRIPTION
	$Tool/Sprite2D.texture = load("res://prescription-icon.ase")

func _on_iv_fluid_pressed() -> void:
	currentTool = Tools.IV_FLUID
	$Tool/Sprite2D.texture = load("res://iv-fluid.png")


func _on_texture_button_2_pressed() -> void:
	if current_patient != LAST_PATIENT:
		nextPatient()
	else:
		endGame()

func _on_prescribe_pressed() -> void:
	if currentTool == Tools.PRESCRIPTION and !medicinePrescribed:
		medicinePrescribed = true
		$ToolUsePopup.show()
		$ToolUsePopup.text = "Medicine prescribed!"
		$ToolUsePopup/AnimationPlayer.play("popup_fade")
