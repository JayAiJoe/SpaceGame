extends Area3D
class_name PickUpItem

var item_info := {}

func _ready():
	randomize_item()

func randomize_item() -> void:
	set_item(Items.get_random_item())

func set_item(item : Dictionary) -> void:
	item_info = item
	if item_info.has("sprite"):
		$Sprite3D.texture = load(item_info["sprite"])
	

func interact(player: Player) -> void:
	if player.add_to_inventory(item_info):
		queue_free()
