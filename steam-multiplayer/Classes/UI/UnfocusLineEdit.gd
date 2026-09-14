extends LineEdit
class_name UnfocusLineEdit

func _ready() -> void:
	editing_toggled.connect(_editing)

func _is_pos_in(checkpos:Vector2) -> bool:
	var gr=get_global_rect()
	return checkpos.x>=gr.position.x and checkpos.y>=gr.position.y and checkpos.x<gr.end.x and checkpos.y<gr.end.y

func _input(event) -> void:
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		text_submitted.emit(text)
		release_focus()

func _editing(toggled: bool) -> void:
	if toggled:
		text = ""
