extends Node2D


func _on_area_2d_11_body_entered(body: Node2D) -> void:
	get_tree().reload_current_scene()


func _on_area_2d_16_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://nivel1/nivel.1.tscn")
	pass # Replace with function body.
