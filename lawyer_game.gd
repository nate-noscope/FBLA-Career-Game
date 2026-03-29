extends Node2D

var balloon
var evidences := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	balloon = DialogueManager.show_dialogue_balloon(load("res://court_case.dialogue"), "start")
	await get_tree().process_frame
	balloon.line_changed.connect(_on_line_changed)
	_on_line_changed(Globals.current_line)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


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
