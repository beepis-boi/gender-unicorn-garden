extends Camera3D
#find the herd
@export var herd_manager: Node3D 
@export var overview_offset: Vector3 = Vector3(0, 16, 25)
#stuff to control how the zoom works
@export var zoom_distance: float = 4.0 
@export var zoom_height: float = 2.0  
@export var zoom_duration: float = 15.0 
#speed variables
@export var transition_speed: float = 3.5
@export var zoom_transition_speed: float = 1.0

var target_horse: Node3D = null
var is_zoomed: bool = false
var zoom_timer: float = 0.0

#smoothing the camera movements
var smoothed_herd_center: Vector3 = Vector3.ZERO
var current_look_target: Vector3 = Vector3.ZERO
#runs when the project starts, points the camera to the herd's center
func _ready() -> void:
	if herd_manager and herd_manager.has_signal("horse_spawned"):
		herd_manager.connect("horse_spawned", _on_horse_spawned)
	
	if herd_manager and herd_manager.has_method("get_herd_center"):
		smoothed_herd_center = herd_manager.get_herd_center()
		current_look_target = smoothed_herd_center
#runs every frame, zooms in and out on the respective timers
func _process(delta: float) -> void:
	if is_zoomed:
		zoom_timer += delta
		if zoom_timer >= zoom_duration or not is_instance_valid(target_horse):
			is_zoomed = false
			if has_node("HorseHUD"): 
				get_node("HorseHUD").is_active = false
			
	var desired_pos: Vector3
	var desired_look: Vector3
	
	var raw_center = Vector3.ZERO
	if herd_manager and herd_manager.has_method("get_herd_center"):
		raw_center = herd_manager.get_herd_center()
	#get the front of the unicorn to point to
	if is_zoomed and is_instance_valid(target_horse):
		var horse_pos = target_horse.global_position
		desired_look = horse_pos + Vector3(0, 0.8, 0)
		
		var horse_forward = target_horse.global_transform.basis.z
		desired_pos = horse_pos + (horse_forward * zoom_distance) + Vector3(0, zoom_height, 0)
	else:
		#more smoothing
		smoothed_herd_center = smoothed_herd_center.lerp(raw_center, 1.0 - exp(-3.0 * delta))
		desired_look = smoothed_herd_center
		desired_pos = smoothed_herd_center + overview_offset
	
	
	var active_speed = zoom_transition_speed if is_zoomed else transition_speed
	var pos_smooth_factor = 1.0 - exp(-active_speed * delta)
	var look_smooth_factor = 1.0 - exp(-6.0 * delta)
	
	current_look_target = current_look_target.lerp(desired_look, look_smooth_factor)
	global_position = global_position.lerp(desired_pos, pos_smooth_factor)
	
	look_at(current_look_target, Vector3.UP)
#runs when a horse spawns, displays their profile and sets the newest horse as the target
func _on_horse_spawned(horse: Node3D, spawn_index: int) -> void:
	target_horse = horse
	is_zoomed = true
	zoom_timer = 0.0
	
	if has_node("HorseHUD"):
		get_node("HorseHUD").is_active = true
