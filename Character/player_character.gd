extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 4.5
const LOOK_AHEAD_DISPLACEMENT = 1.0

@onready var anim_tree = $SpriteAnchor/AnimationTree
@onready var cam_rig = $CameraRig

var prev_char_dir := Vector2(1, 0) # XZ-direction
var target_cam_pos : Vector3



func _physics_process(delta):
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		prev_char_dir = Vector2(sign(direction.x), sign(direction.z))
		anim_tree.get("parameters/playback").travel("Walk")
		anim_tree.set("parameters/Walk/BlendSpace1D/blend_position", prev_char_dir.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		anim_tree.get("parameters/playback").travel("Idle")
		anim_tree.set("parameters/Idle/BlendSpace1D/blend_position", prev_char_dir.x)
		

	move_and_slide()
	
	# Camera
	var look_ahead = prev_char_dir.normalized() * LOOK_AHEAD_DISPLACEMENT
	target_cam_pos = lerp(target_cam_pos, global_position + Vector3(look_ahead.x, 0, look_ahead.y), 0.1)
	
	
	if cam_rig:
		cam_rig.global_position.x = target_cam_pos.x 
		cam_rig.global_position.y = target_cam_pos.y
		cam_rig.global_position.z = min(-3, target_cam_pos.z)
