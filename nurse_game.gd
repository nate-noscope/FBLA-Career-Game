extends Node2D

enum Tools{NONE, PLASTER, PRESCRIPTION, IV_FLUID}
const MAX_ARM_CLICKS = 3
const LAST_PATIENT = 3

var time := 0.0
var current_patient := 1
var correct_tool_uses := 0
var incorrect_tool_uses := 0
var approval := 0
var isToolsOut := false
var isTicking := false
var currentTool := Tools.NONE
var castOn := false
var ivOn := false
var medicinePrescribed := false
var armClicks := 0

var soaps := ["Subjective:
Patient says he got a deep cut on his leg from broken glass and concrete rubble during the earthquake. He cleaned it himself at the time but did not seek medical care. He now says the area around the cut feels hot and is getting more painful, not less. He has been feeling tired and off since yesterday and says he had the chills last night.
Objective:
There is a 4 cm laceration on the left lower leg that has been closed with improvised bandaging. The skin around the wound is red, warm to the touch, and swollen. A small amount of cloudy yellowish fluid is seeping from the wound edges. He has a temperature of 101.8°F and his heart rate is elevated. The wound does not appear deep enough to involve the bone.
",
"Subjective:
Patient says his left arm got pinned under a heavy piece of debris while he was at work during the earthquake. He is in a lot of pain and says it started hurting immediately. He cannot move his wrist or fingers and is very worried his arm \"looks wrong.\" He has no other injuries and was awake and alert the whole time.
Objective:
The left forearm is badly swollen and bruised with a visible bend in the middle that should not be there. The skin is not broken. His heart rate is fast and he appears to be in significant pain. His urine, collected on arrival, is a dark brownish color. X-rays show the bones in his forearm are broken and out of place.
",
"Subjective:
Patient says he was inside a building when the earthquake hit and got very frightened. He ran outside and tripped on some rubble, landing on both hands. He says his palms are a little sore but nothing feels seriously wrong. He came in mainly because he has been feeling shaky and anxious since the event and wanted to make sure everything was okay.
Objective:
Both palms have minor scrapes with no deep cuts or bleeding. The skin is intact around all fingers and there is no swelling or deformity anywhere on the hands or wrists. He moves all fingers freely and without pain. His temperature, heart rate, and breathing are all normal. He appears anxious but is calm and speaking clearly.
"
]

func _ready() -> void:
	playEnding()
	#var balloon := DialogueManager.show_dialogue_balloon(load("res://nurse_game_intro.dialogue"), "start")
	#balloon.tree_exited.connect(func():
		#$ColorRect.hide()
		#isTicking = true)
	$PatientNotes/ScrollContainer/NotesLabel.text = soaps[0]

func _process(delta: float) -> void:
	if isTicking:
		time += delta
		$Time/TimeLabel.text = str(snapped(time, 0.1))

##check func (can be used for any checkbox)
func checkBox(box : AnimatedSprite2D, satisfied := false):
	if satisfied:
		box.play("check")
	else:
		box.play("cross")

func check1():
	checkBox($CanvasLayer/Node2D/Clipboard/Checkbox, correct_tool_uses >= 1)

func check2():
	checkBox($CanvasLayer/Node2D/Clipboard/Checkbox2, incorrect_tool_uses <= 1)

func nextPatient():
	$BlackFade/AnimationPlayer.play("fade_to_black")
	await get_tree().create_timer(1.0).timeout
	var tex = "res://approval-faces/approval-faces5.png"
	match approval:
		3:
			tex = load("res://approval-faces/approval-faces1.png")
		2:
			tex = load("res://approval-faces/approval-faces1.png")
		1:
			tex = load("res://approval-faces/approval-faces2.png")
		0:
			tex = load("res://approval-faces/approval-faces2.png")
		-1:
			tex = load("res://approval-faces/approval-faces3.png")
		-2:
			tex = load("res://approval-faces/approval-faces4.png")
		-3:
			tex = load("res://approval-faces/approval-faces4.png")
	$Approval/Sprite2D.texture = tex
	current_patient += 1
	castOn = false
	ivOn = false
	medicinePrescribed = false
	$PatientNotes/ScrollContainer/NotesLabel.text = soaps[current_patient - 1]
	if current_patient == 2:
		$Patient.play("idle_normal2")
	elif current_patient == 3:
		$Patient.play("idle_normal3")
	$BlackFade/AnimationPlayer.play("fade_from_black")

func playEnding() -> void:
	$CanvasLayer/Node2D/Clipboard/AnimationPlayer.play("review")
	await get_tree().create_timer(6.0).timeout
	var approval_name := "Poor"
	match approval:
		3:
			approval_name = "Great"
		2:
			approval_name = "Great"
		1:
			approval_name = "Good"
		0:
			approval_name = "Good"
		-1:
			approval_name = "Decent"
		-2:
			approval_name = "Low"
		-3:
			approval_name = "Low"
	$CanvasLayer/Node2D/Clipboard/Label2.text += " " + approval_name
	await get_tree().create_timer(2.0).timeout
	var grade := "F"
	if approval >= 3:
		grade = "A+"
	elif approval == 2:
		grade = "A-"
	elif approval == 1:
		grade = "B"
	elif approval == 0:
		grade = "C"
	else:
		grade = "D"
	$CanvasLayer/Node2D/Clipboard/ScoreLabel.text = "Grade: " + grade
	await get_tree().create_timer(2.0).timeout
	$BlackFade/AnimationPlayer.play("fade_to_black")
	await $BlackFade/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://menu_screen.tscn")

func _on_texture_button_pressed() -> void:
	if isToolsOut:
		$TextureButton/AnimationPlayer.play("slide_left")
		isToolsOut = false
	else:
		$TextureButton/AnimationPlayer.play("slide_right")
		isToolsOut = true

func _on_arm_pressed() -> void:
	if currentTool == Tools.PLASTER:
		armClicks += 1
		if armClicks >= MAX_ARM_CLICKS:
			castOn = true
			match current_patient:
				1:
					$Patient.play("idle_cast")
				2:
					$Patient.play("idle_cast2")
				3:
					$Patient.play("idle_cast3")
			$ToolUsePopup.text = "Cast applied!"
			$ToolUsePopup/AnimationPlayer.play("popup_fade")

func _on_left_hand_pressed() -> void:
	if currentTool == Tools.IV_FLUID and !ivOn:
		ivOn = true
		if current_patient == 2:
			correct_tool_uses += 1
		else:
			incorrect_tool_uses += 1
		$ToolUsePopup.text = "IV added!"
		$ToolUsePopup/AnimationPlayer.play("popup_fade")

func _on_plaster_roll_pressed() -> void:
	if current_patient == 2:
		correct_tool_uses += 1
	else:
		incorrect_tool_uses += 1
	currentTool = Tools.PLASTER
	$Tool/Sprite2D.texture = load("res://plaster-roll-icon.png")

func _on_prescription_pressed() -> void:
	currentTool = Tools.PRESCRIPTION
	$Tool/Sprite2D.texture = load("res://prescription-icon.ase")

func _on_iv_fluid_pressed() -> void:
	currentTool = Tools.IV_FLUID
	$Tool/Sprite2D.texture = load("res://iv-fluid.png")

func _on_texture_button_2_pressed() -> void:
	approval = correct_tool_uses - incorrect_tool_uses
	if current_patient != LAST_PATIENT:
		nextPatient()
	else:
		playEnding()

func _on_prescribe_pressed() -> void:
	if currentTool == Tools.PRESCRIPTION and !medicinePrescribed:
		if current_patient == 1:
			correct_tool_uses += 1
		else:
			incorrect_tool_uses += 1
		medicinePrescribed = true
		$ToolUsePopup.text = "Medicine prescribed!"
		$ToolUsePopup/AnimationPlayer.play("popup_fade")
