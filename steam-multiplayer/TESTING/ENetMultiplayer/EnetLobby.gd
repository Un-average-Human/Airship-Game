extends Node3D




func _on_client_pressed() -> void:
	LarpNetworking.start_client()


func _on_server_pressed() -> void:
	LarpNetworking.start_server()
