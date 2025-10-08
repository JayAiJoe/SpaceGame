extends Control


var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.player_statuses_updated.connect(_on_player_status_updated)
	Events.player_inventory_updated.connect(_on_player_inventory_updated)


func _on_player_status_updated(p : Player, status_values : Array) -> void:
	if p != player:
		return
	set_status_values(status_values)

func set_status_values(status_values : Array) -> void:
	var bars = %StatusBar.get_children() 
	for i in range(status_values.size()):
		bars[i].size_flags_stretch_ratio = status_values[i]

func _on_player_inventory_updated(p : Player, inventory : Array[Dictionary]) -> void:
	if p != player:
		return
	for i in range(inventory.size()):
		if inventory[i].has("sprite"):
			%InventoryItems.get_child(i).get_child(0).texture = load(inventory[i]["sprite"])
			
		
