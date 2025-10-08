extends Node3D

@onready var hud = $HUDMesh
@onready var player = $Player

func _ready():
	hud.hide()
	Events.player_viewed_hud.connect(_on_player_view_hud)
	Events.player_exited_hud.connect(_on_player_exit_hud)
	%HUD.player = player


func _input(event):
	if event.is_action_pressed("escape"):
		get_tree().quit()

func _on_player_view_hud() -> void:
	hud.show()

func _on_player_exit_hud() -> void:
	hud.hide()

func _process(_delta):
	if hud.visible:
		hud.global_position = player.get_target_hud_position()
