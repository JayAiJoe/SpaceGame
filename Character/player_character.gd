extends CharacterBody3D
class_name Player


const WALK_SPEED = 4.0
const SPRINT_SPEED = 6.0
const SNEAK_SPEED = 1.5
const ACCELERATION = 50.0
const STAMINA_CONSUMPTION = 10.0
const STAMINA_RECOVERY = -8.0
const RECOVERY_DELAY = 1.25

const JUMP_VELOCITY = 4.5
const LOOK_AHEAD_DISPLACEMENT = 1.85

@onready var anim_tree = $SpriteAnchor/AnimationTree
@onready var cam_rig = $CameraRig
@onready var camera_marker = $CameraRig/CameraAnchor/CameraMarker
@onready var playback : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

#movement
var prev_char_dir := Vector2(1, 0) # XZ-direction
var look_direction := 1 #X-direction
var is_holding_spint := false
var is_holding_sneak := false
var movement_locked := false
var prev_movement_type := "idle"

#stamina
var recovering_stamina := false

#camera
var target_cam_pos : Vector3
var room_camera_transform : Transform3D
var is_viewing_hud := false

#interact
var interactables_in_range := []

#inventory
var inventory_manager := InventoryManager.new()

#status
var status_manager : StatusManager = StatusManager.new()

func _ready():
	$RecoveryTimer.wait_time = RECOVERY_DELAY

func _input(event):
	if event.is_action_pressed("interact"):
		if playback.get_current_node() == "Idle" and interactables_in_range.size() > 0:
			playback.travel("Interact")
			anim_tree.set("parameters/Interact/BlendSpace1D/blend_position", look_direction)
			interactables_in_range[0].interact(self)
	if event.is_action_pressed("tab"):
		if !is_viewing_hud:
			room_camera_transform = GameCamera.global_transform
			GameCamera.transition_to(camera_marker.global_transform, 0.3, Tween.EASE_OUT, Tween.TRANS_CIRC)
			lock_movement()
			is_viewing_hud = true
			Events.player_viewed_hud.emit()
		else:
			GameCamera.transition_to(room_camera_transform, 0.3, Tween.EASE_OUT, Tween.TRANS_CIRC)
			unlock_movement()
			is_viewing_hud = false
			Events.player_exited_hud.emit()
			


func lock_movement() -> void:
	movement_locked = true
	velocity = Vector3.ZERO

func unlock_movement() -> void:
	movement_locked = false

func _process(_delta):
	Events.player_statuses_updated.emit(self, status_manager.get_status_ratios())


func _physics_process(delta):
		
	is_holding_spint = Input.is_action_pressed("sprint")
	is_holding_sneak = Input.is_action_pressed("sneak")
	
	var movement_type := "idle"
	
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
	if direction and !movement_locked:
		
		movement_type = "walk"
		if is_holding_spint and status_manager.get_status_value("health") > 0:
			movement_type = "sprint"
		if is_holding_sneak:
			movement_type = "sneak"
		
		prev_char_dir = Vector2(sign(direction.x), sign(direction.z))
		if sign(direction.x) != 0:
			look_direction = sign(direction.x)
		
			
		
		match(movement_type):
			"walk":
				velocity.x = move_toward(velocity.x, WALK_SPEED * direction.x, ACCELERATION * delta)
				velocity.z = move_toward(velocity.z, WALK_SPEED * direction.z, ACCELERATION * delta)
				playback.travel("Walk")
				anim_tree.set("parameters/Walk/BlendSpace1D/blend_position", look_direction)
			"sprint":
				recovering_stamina = false
				status_manager.add_status("consumed_stamina", STAMINA_CONSUMPTION * delta)
				velocity.x = move_toward(velocity.x, SPRINT_SPEED * direction.x, ACCELERATION * delta)
				velocity.z = move_toward(velocity.z, SPRINT_SPEED * direction.z, ACCELERATION * delta)
				playback.travel("Sprint")
				anim_tree.set("parameters/Sprint/BlendSpace1D/blend_position", look_direction)
			"sneak":
				velocity.x = move_toward(velocity.x, SNEAK_SPEED * direction.x, ACCELERATION * delta)
				velocity.z = move_toward(velocity.z, SNEAK_SPEED * direction.z, ACCELERATION * delta)
				playback.travel("Sneak")
				anim_tree.set("parameters/Sneak/BlendSpace1D/blend_position", look_direction)
			
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, ACCELERATION * delta)
		
		if is_holding_sneak:
			playback.travel("SneakIdle")
			anim_tree.set("parameters/SneakIdle/BlendSpace1D/blend_position", look_direction)
		else:
			playback.travel("Idle")
			anim_tree.set("parameters/Idle/BlendSpace1D/blend_position", look_direction)
	
	#stamina recovery
	if recovering_stamina:
		status_manager.add_status("consumed_stamina", STAMINA_RECOVERY * delta)
	if prev_movement_type == "sprint" and movement_type != "sprint":
		$RecoveryTimer.start()
	prev_movement_type = movement_type
		
	move_and_slide()
	# Camera
	#var look_ahead = prev_char_dir.normalized() * LOOK_AHEAD_DISPLACEMENT
	cam_rig.global_position = global_position + Vector3(look_direction * LOOK_AHEAD_DISPLACEMENT, 0, 0) 


func _on_recovery_timer_timeout():
	recovering_stamina = true


func _on_interact_area_body_entered(body):
	if body.is_in_group("Interactables"):
		interactables_in_range.append(body)


func _on_interact_area_body_exited(body):
	if body in interactables_in_range:
		interactables_in_range.erase(body)


func _on_interact_area_area_entered(area):
	if area.is_in_group("Interactables"):
		interactables_in_range.append(area)


func _on_interact_area_area_exited(area):
	if area in interactables_in_range:
		interactables_in_range.erase(area)

func get_target_hud_position() -> Vector3:
	return $CameraRig/CameraAnchor.global_position

func add_to_inventory(item : Dictionary) -> bool:
	if inventory_manager.add_to_inventory(item):
		Events.player_inventory_updated.emit(self, inventory_manager.get_inventory())
		return true
	return false
