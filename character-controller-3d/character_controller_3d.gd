extends CharacterBody3D
class_name CharacterController3D

const HEAD_LOOK_CLAMP_UP: float = 0.85
const HEAD_LOOK_CLAMP_DOWN: float = -0.85


@export_category("Settings")
@export var mouse_sensitivity = 0.01
@export var max_run_speed = 5.0
@export var walk_speed_modifier = 0.2
@export var jump_velocity = 4.5

@export_category("Static Settings")
@export var camera: Camera3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		var ray_length = 500
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_query = PhysicsRayQueryParameters3D.new()
		var space = get_world_3d().direct_space_state
		ray_query.from = camera.project_ray_origin(mouse_pos)
		ray_query.to = ray_query.from + camera.project_ray_normal(mouse_pos) * ray_length
		ray_query.collide_with_areas = true
		var raycast_result = space.intersect_ray(ray_query)
		print(raycast_result)
		print(raycast_result.collider.name)
		if raycast_result.collider is Interactable3D: print("This is an interactable.")


func _physics_process(delta):
	if not is_on_floor(): velocity.y -= gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"): 
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_movement: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_movement.x, 0, input_movement.y)).normalized()
	if direction:
		var new_movement_velocity = Vector3.ZERO
		new_movement_velocity.x = direction.x * max_run_speed
		new_movement_velocity.y = velocity.y
		new_movement_velocity.z = direction.z * max_run_speed
		if is_on_floor() and Input.is_action_pressed("walk_hold"): new_movement_velocity *= walk_speed_modifier
		velocity = new_movement_velocity
	else:
		velocity.x = move_toward(velocity.x, 0, max_run_speed)
		velocity.z = move_toward(velocity.z, 0, max_run_speed)
	
	# Rotations
	var input_mouse: Vector2 = Input.get_last_mouse_velocity()
	if input_mouse:
		rotate_y(-input_mouse.x * mouse_sensitivity * delta)
		var new_camera_rotation_pitch: float = camera.rotation.x + (input_mouse.y * mouse_sensitivity * delta)
		camera.rotation.x = clamp(new_camera_rotation_pitch, HEAD_LOOK_CLAMP_DOWN, HEAD_LOOK_CLAMP_UP)
	move_and_slide()
