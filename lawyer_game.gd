extends Node2D

var balloon

func _ready() -> void:
	DialogueManager.show_dialogue_balloon(load("res://lawyer_game_intro.dialogue"), "start")

##check func (can be used for any checkbox)
func checkBox(box : AnimatedSprite2D, satisfied := false):
	if satisfied:
		box.play("check")
	else:
		box.play("cross")

func check1():
	checkBox($CanvasLayer/Node2D/Clipboard/Checkbox, Globals.evidence_score >= 1)

func check2():
	checkBox($CanvasLayer/Node2D/Clipboard/Checkbox2, Globals.court_score >= 1)

func startCourtCase():
	$BlackFade/AnimationPlayer.play("fade_to_black")
	await $BlackFade/AnimationPlayer.animation_finished
	$EvidencePicking.hide()
	$Courtroom/JudgeLayer.show()
	$BlackFade/AnimationPlayer.play("fade_from_black")
	await $BlackFade/AnimationPlayer.animation_finished
	balloon = DialogueManager.show_dialogue_balloon(load("res://court_case.dialogue"), "start")
	await get_tree().process_frame
	balloon.line_changed.connect(_on_line_changed)
	balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
	balloon.tree_exited.connect(_on_dialogue_ended)
	var line = Globals.current_line
	if line.character == "Lawyer":
		$Courtroom/LawyerLayer.show()
		$Courtroom/JudgeLayer.hide()
		$Courtroom/ProsecutorLayer.hide()
		if "pointing" in line.tags:
			$Courtroom/LawyerLayer/Lawyer.play("pointing_talk")
		elif "table" in line.tags:
			$Courtroom/LawyerLayer/Lawyer.play("touch_table_talk")
		else:
			$Courtroom/LawyerLayer/Lawyer.play("normal_talk")
	elif line.character == "Judge":
		$Courtroom/LawyerLayer.hide()
		$Courtroom/JudgeLayer.show()
		$Courtroom/ProsecutorLayer.hide()
		if "surprised" in line.tags:
			$Courtroom/JudgeLayer/Judge.play("surprised_talk")
		else:
			$Courtroom/JudgeLayer/Judge.play("normal_talk")
	elif line.character == "Prosecutor":
		$Courtroom/LawyerLayer.hide()
		$Courtroom/JudgeLayer.hide()
		$Courtroom/ProsecutorLayer.show()
		$Courtroom/ProsecutorLayer/Prosecutor.play("normal_talk")
		if "surprised" in line.tags:
			$Courtroom/ProsecutorLayer/Prosecutor.play("surprised_talk")
		else:
			$Courtroom/ProsecutorLayer/Prosecutor.play("normal_talk")

func _on_line_changed(line):
	if line.character == "Lawyer":
		$Courtroom/LawyerLayer.show()
		$Courtroom/JudgeLayer.hide()
		$Courtroom/ProsecutorLayer.hide()
		if "pointing" in line.tags:
			$Courtroom/LawyerLayer/Lawyer.play("pointing_talk")
		elif "table" in line.tags:
			$Courtroom/LawyerLayer/Lawyer.play("touch_table_talk")
		else:
			$Courtroom/LawyerLayer/Lawyer.play("normal_talk")
	elif line.character == "Judge":
		$Courtroom/LawyerLayer.hide()
		$Courtroom/JudgeLayer.show()
		$Courtroom/ProsecutorLayer.hide()
		if "surprised" in line.tags:
			$Courtroom/JudgeLayer/Judge.play("surprised_talk")
		else:
			$Courtroom/JudgeLayer/Judge.play("normal_talk")
	elif line.character == "Prosecutor":
		$Courtroom/LawyerLayer.hide()
		$Courtroom/JudgeLayer.hide()
		$Courtroom/ProsecutorLayer.show()
		$Courtroom/ProsecutorLayer/Prosecutor.play("normal_talk")
		if "surprised" in line.tags:
			$Courtroom/ProsecutorLayer/Prosecutor.play("surprised_talk")
		else:
			$Courtroom/ProsecutorLayer/Prosecutor.play("normal_talk")

func _on_finished_typing():
	$Courtroom/LawyerLayer/Lawyer.stop()
	$Courtroom/JudgeLayer/Judge.stop()
	$Courtroom/ProsecutorLayer/Prosecutor.stop()

func _on_dialogue_ended() -> void:
	playEnding()

func playEnding() -> void:
	$CanvasLayer/Node2D/Clipboard/AnimationPlayer.play("review")
	await get_tree().create_timer(6.0).timeout
	$CanvasLayer/Node2D/Clipboard/Label2.text = "Verdict: Insurance Pays"
	await get_tree().create_timer(2.0).timeout
	var score := Globals.evidence_score + Globals.court_score
	var grade := "F"
	if score >= 4:
		grade = "A"
	elif score == 3:
		grade = "A-"
	elif score == 2:
		grade = "B"
	elif score == 1:
		grade = "C"
	else:
		grade = "D"
	$CanvasLayer/Node2D/Clipboard/ScoreLabel.text = "Grade: " + grade
	await get_tree().create_timer(2.0).timeout
	$BlackFade/AnimationPlayer.play("fade_to_black")
	await $BlackFade/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://menu_screen.tscn")

func _on_texture_button_2_pressed() -> void:
	if Globals.evidence1 != -1 and Globals.evidence2 != -1:
		if Globals.evidence1 == 1:
			Globals.evidence_score += 1
		if Globals.evidence2 == 4:
			Globals.evidence_score += 1
		startCourtCase()

func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.evidence1 = 1

func _on_check_box_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.evidence1 = 2

func _on_check_box_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.evidence2 = 3

func _on_check_box_4_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.evidence2 = 4
