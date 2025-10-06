extends CharacterBody3D


const WALK_SPEED = 4.0
const SPRINT_SPEED = 6.0
const SNEAK_SPEED = 1.5
const ACCELERATION = 0.75

const JUMP_VELOCITY = 4.5
const LOOK_AHEAD_DISPLACEMENT = 0.0

@onready var anim_tree = $SpriteAnchor/AnimationTree
@onready var cam_rig = $CameraRig
@onready var playback : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

#movement
var prev_char_dir := Vector2(1, 0) # XZ-direction
var is_holding_spint := false
var is_holding_sneak := false
var movement_locked := false

#camera
var target_cam_pos : Vector3

func _input(event):
	if event.is_action_pressed("interact"):
		if playback.get_current_node() == "Idle":
			playback.travel("Interact")
			anim_tree.set("parameters/Interact/BlendSpace1D/blend_position", prev_char_dir.x)


func lock_movement() -> void:
	movement_locked = true
	velocity = Vector3.ZERO

func unlock_movement() -> void:
	movement_locked = false



func _physics_process(delta):
	if movement_locked:
		return
		
	is_holding_spint = Input.is_action_pressed("sprint")
	is_holding_sneak = Input.is_action_pressed("sneak")
	
	var movement_type := "walk"
	if is_holding_spint:
		movement_type = "sprint"
	if is_holding_sneak:
		movement_type = "sneak"
	
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
		
		prev_char_dir = Vector2(sign(direction.x), sign(direction.z))
		match(movement_type):
			"walk":
				velocity.x = move_toward(velocity.x, WALK_SPEED * direction.x, ACCELERATION)
				velocity.z = move_toward(velocity.z, WALK_SPEED * direction.z, ACCELERATION)
				playback.travel("Walk")
				anim_tree.set("parameters/Walk/BlendSpace1D/blend_position", prev_char_dir.x)
			"sprint":
				velocity.x = move_toward(velocity.x, SPRINT_SPEED * direction.x, ACCELERATION)
				velocity.z = move_toward(velocity.z, SPRINT_SPEED * direction.z, ACCELERATION)
				playback.travel("Sprint")
				anim_tree.set("parameters/Sprint/BlendSpace1D/blend_position", prev_char_dir.x)
			"sneak":
				velocity.x = move_toward(velocity.x, SNEAK_SPEED * direction.x, ACCELERATION)
				velocity.z = move_toward(velocity.z, SNEAK_SPEED * direction.z, ACCELERATION)
				playback.travel("Sneak")
				anim_tree.set("parameters/Sneak/BlendSpace1D/blend_position", prev_char_dir.x)
			
		
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)
		velocity.z = move_toward(velocity.z, 0, ACCELERATION)
		
		if is_holding_sneak:
			playback.travel("SneakIdle")
			anim_tree.set("parameters/SneakIdle/BlendSpace1D/blend_position", prev_char_dir.x)
		else:
			playback.travel("Idle")
			anim_tree.set("parameters/Idle/BlendSpace1D/blend_position", prev_char_dir.x)
		

	move_and_slide()
	
	
	
	# Camera
	var look_ahead = prev_char_dir.normalized() * LOOK_AHEAD_DISPLACEMENT
	target_cam_pos = lerp(target_cam_pos, global_position + Vector3(look_ahead.x, 0, look_ahead.y), 0.1)
	
	
	if cam_rig:
		cam_rig.global_position.x = target_cam_pos.x 
		cam_rig.global_position.y = target_cam_pos.y
		cam_rig.global_position.z = min(-3, target_cam_pos.z)
