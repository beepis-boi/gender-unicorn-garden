extends CanvasLayer

@export var herd_manager: Node3D
@export var camera: Camera3D
#references to the ui elements
@onready var panel: Panel = $Panel
@onready var header_label: Label = $Panel/VBoxContainer/Header
@onready var gender_label: Label = $Panel/VBoxContainer/Gender
@onready var phys_label: Label = $Panel/VBoxContainer/Phys
@onready var rom_label: Label = $Panel/VBoxContainer/Rom

var current_target_horse: Node3D = null
var is_active: bool = false
const UI_OFFSET: Vector2 = Vector2(40, -20)
#shows the panel when the project starts up
func _ready() -> void:
	panel.show()
	if herd_manager and herd_manager.has_signal("horse_spawned"):
		herd_manager.connect("horse_spawned", _on_horse_spawned)
#runs every frame and controls when and when not to show the profile
func _process(_delta: float) -> void:
	if camera and "is_zoomed" in camera and not camera.is_zoomed:
		panel.hide()
		is_active = false
		return

	if not is_active or not is_instance_valid(current_target_horse) or not camera:
		panel.hide()
		return
	

	var horse_world_pos = current_target_horse.global_position + Vector3(0, 1.0, 0)
	
	if camera.is_position_behind(horse_world_pos):
		panel.hide()
		return
		
	var screen_pos = camera.unproject_position(horse_world_pos)
	panel.global_position = screen_pos + UI_OFFSET
	panel.show()
#sets the text to be displayed on each line
func _on_horse_spawned(horse: Node3D, spawn_index: int) -> void:
	current_target_horse = horse
	is_active = true
	
	header_label.text = "Unicorn #" + str(spawn_index)
	gender_label.text = "Gender: " + horse.get_gender_string()
	phys_label.text = "Physically attracted to: " + horse.get_rom_string()
	rom_label.text = "Romantically attracted to: " + horse.get_phys_string()
		
	panel.show()
