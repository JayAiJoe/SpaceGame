extends Node


var db = {}

func _ready():
	var file = FileAccess.open("res://Items/items.json", FileAccess.READ)
	db = JSON.parse_string(file.get_as_text())

func get_item(id: String) -> Dictionary:
	return db.get(id)

func get_random_item() -> Dictionary:
	return db.values()[randi()%db.size()]
