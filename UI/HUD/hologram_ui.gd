extends Area3D


@onready var mesh: MeshInstance3D = $HUDMesh
@onready var viewport: Viewport = $SubViewport
@onready var mat = $HUDMesh.material_override

var player: Player




func _ready():
	var shape = BoxShape3D.new()
	shape.size = Vector3(mesh.mesh.size.x, mesh.mesh.size.y, 0.01)
	$CollisionShape3D.shape = shape
	if mat is ShaderMaterial:
		mat.set_shader_parameter("ui_tex", viewport.get_texture())

func set_player(p : Player)-> void:
	player = p
	%HUD.player = player

func _on_input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	# Convert 3D position to UV coords
	var quad = mesh.mesh as QuadMesh
	var local_pos = mesh.to_local(position)
	var size = quad.size
	var uv = Vector2(
		(local_pos.x / size.x) + 0.5,
		-(local_pos.y / size.y) + 0.5
	)
	
	# Convert to Viewport pixel coords
	var vp_pos = uv * Vector2(viewport.size)

	# Clone and forward the event
	var ev = event.duplicate()
	if ev is InputEventMouse:
		ev.position = vp_pos
	viewport.push_input(ev)
