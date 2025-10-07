extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.player_statuses_updated.connect(_on_player_status_update)


func _on_player_status_update(player, status_values) -> void:
	set_status_values(status_values)
	


func set_status_values(status_values : Array) -> void:
	var bars = get_children() 
	for i in range(status_values.size()):
		bars[i].size_flags_stretch_ratio = status_values[i]
		
