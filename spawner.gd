extends Node3D
#gets the base unicorn, and sets variables related to herd size, range, and spawn intervals
@export var horse_scene: PackedScene
@export var herd_size: int = 36
@export var spawn_min_range: float = 24.0
@export var spawn_max_range: float = 72.0
@export var replacement_interval: float = 30.0

var horses: Array[Node3D] = []
var replacement_timer: float = 0.0
var total_spawned_count: int = 0
#defines a signal that will later be sent out to the rest of the program when a horse spawns
signal horse_spawned(horse: Node3D, spawn_index: int)
#create the first batch when the project starts
func _ready() -> void:
	for i in range(herd_size):
		spawn_horse()
#checks if the timer is up every frame, then cycle out the horses if it is
func _process(delta: float) -> void:
	replacement_timer += delta
	if replacement_timer >= replacement_interval:
		replacement_timer = 0.0
		cycle_oldest_horse()
#when a horse spawns, it sends out the signal to the rest of the program, it increments a counter,
#and puts them at a random location and rotation
func spawn_horse() -> void:
	total_spawned_count += 1
	var horse = horse_scene.instantiate() as Node3D
	
	var angle = randf() * TAU
	var dist = randf_range(spawn_min_range, spawn_max_range)
	
	horse.position = Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	
	add_child(horse)
	horses.append(horse)
	
	emit_signal("horse_spawned", horse, total_spawned_count)
	
#gets rid of the oldest horse when a new one spawns
func cycle_oldest_horse() -> void:
	if horses.is_empty():
		return
	
	var oldest_horse = horses.pop_front()
	if is_instance_valid(oldest_horse):
		oldest_horse.queue_free()
	
	spawn_horse()

#gets the center of the herd for the camera
func get_herd_center() -> Vector3:
	if horses.is_empty():
		return global_position
	
	var sum = Vector3.ZERO
	var valid_count = 0
	
	for horse in horses:
		if is_instance_valid(horse):
			sum += horse.global_position
			valid_count += 1
			
	if valid_count == 0:
		return global_position
		
	return sum / valid_count
