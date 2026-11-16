extends Node3D
#lots of variables used to point the engine to the materials that need to be changed
@export var mane_materials: Array[Material]
@export var tail_materials: Array[Material]
@export var horn_materials: Array[Material]
@export var eye_materials: Array[Material]

@export var mane_surface_index: int = 1
@export var tail_surface_index: int = 2
@export var horn_surface_index: int = 3
@export var eye_surface_index: int = 4

@onready var mesh_instance: MeshInstance3D = $CharacterBody3D/CollisionShape3D/merged_0_0_node2

# parameters to control how the unicorns hop around
@export var hop_interval_min: float = 2.0
@export var hop_interval_max: float = 5.0
@export var hop_range: float = 3.0
@export var bounds_radius: float = 100.0
#references to the audio players
@onready var hop_sound_player: AudioStreamPlayer3D = $hopAudio
@onready var cry_sound_player: AudioStreamPlayer3D = $cryAudio
#more hopping variables
var hop_timer: float = 0.0
var next_hop_time: float = 3.0
var target_position: Vector3 = Vector3.ZERO
var start_position: Vector3 = Vector3.ZERO
var is_hopping: bool = false
var hop_progress: float = 0.0
var jump_height: float = 0.8
#variables relating to gender, identity, and attraction
var agab: int = 0
var genderid: int = 0
var finalgender: int = 0
var romattract: int = 0
var physattract: int = 0
var finalphys: int = 0
var finalrom: int = 0
#enumerators which let me call  certain keywords as data instead of all being stored as numbers
enum genderidentity {CIS, NB, TRANS, DEMIBOY, DEMIGIRL, AGENDER}
enum attraction {MALE, FEMALE, NEITHER, BI, PAN}
enum finalattractlist {MALE, FEMALE, ASPEC, BI, PAN}
enum assignedbirthgender {MALE, FEMALE}
enum finalgenderlist {MALE, FEMALE, NONBINARY, AGENDER}
enum attractflags {HET, GAY, LESBIAN, BI, PAN, ARO, ACE, SAPPHIC, ACHILEAN}
#character strings to display in the profile
const GENDER_STRINGS = ["Male", "Female", "Nonbinary", "Agender"]
const ATTRACTION_STRINGS = ["Men", "Women", "Neither", "All", "All"]

func get_gender_string() -> String:
	return GENDER_STRINGS[finalgender]

func get_rom_string() -> String:
	return ATTRACTION_STRINGS[romattract]

func get_phys_string() -> String:
	return ATTRACTION_STRINGS[physattract]

#rotation and scale variables
var current_basis: Basis
var target_basis: Basis
var saved_scale: Vector3
#formulas that are called to calculate how the gender identities, birth gender, and attractions all link together to create the final unicorn
func getgender() -> void:
	if agab == assignedbirthgender.MALE:
		if genderid == genderidentity.CIS:
			finalgender = finalgenderlist.MALE
		elif genderid == genderidentity.TRANS:
			finalgender = finalgenderlist.FEMALE
		elif genderid == genderidentity.NB:
			finalgender = finalgenderlist.NONBINARY
		elif genderid == genderidentity.AGENDER:
			finalgender = finalgenderlist.AGENDER
		elif genderid == genderidentity.DEMIBOY:
			finalgender = finalgenderlist.MALE
		elif genderid == genderidentity.DEMIGIRL:
			genderid = genderidentity.TRANS
			finalgender = finalgenderlist.FEMALE
	elif agab == assignedbirthgender.FEMALE:
		if genderid == genderidentity.CIS:
			finalgender = finalgenderlist.FEMALE
		elif genderid == genderidentity.TRANS:
			finalgender = finalgenderlist.MALE
		elif genderid == genderidentity.NB:
			finalgender = finalgenderlist.NONBINARY
		elif genderid == genderidentity.AGENDER:
			finalgender = finalgenderlist.AGENDER
		elif genderid == genderidentity.DEMIGIRL:
			finalgender = finalgenderlist.FEMALE
		elif genderid == genderidentity.DEMIBOY:
			genderid = genderidentity.TRANS
			finalgender = finalgenderlist.MALE

func getphysattr() -> void:
	if finalgender == finalgenderlist.MALE:
		if physattract == attraction.MALE:
			finalphys = attractflags.GAY
		elif physattract == attraction.FEMALE:
			finalphys = attractflags.HET
		elif physattract == attraction.NEITHER:
			finalphys = attractflags.ACE
		elif physattract == attraction.BI:
			finalphys = attractflags.BI
		elif physattract == attraction.PAN:
			finalphys = attractflags.PAN
	if finalgender == finalgenderlist.FEMALE:
		if physattract == attraction.MALE:
			finalphys = attractflags.HET
		elif physattract == attraction.FEMALE:
			finalphys = attractflags.LESBIAN
		elif physattract == attraction.NEITHER:
			finalphys = attractflags.ACE
		elif physattract == attraction.BI:
			finalphys = attractflags.BI
		elif physattract == attraction.PAN:
			finalphys = attractflags.PAN
	if finalgender == finalgenderlist.NONBINARY:
		if physattract == attraction.MALE:
			finalphys = attractflags.ACHILEAN
		elif physattract == attraction.FEMALE:
			finalphys = attractflags.SAPPHIC
		elif physattract == attraction.NEITHER:
			finalphys = attractflags.ACE
		elif physattract == attraction.BI:
			finalphys = attractflags.BI
		elif physattract == attraction.PAN:
			finalphys = attractflags.PAN
	if finalgender == finalgenderlist.AGENDER:
		if physattract == attraction.MALE:
			finalphys = attractflags.ACHILEAN
		elif physattract == attraction.FEMALE:
			finalphys = attractflags.SAPPHIC
		elif physattract == attraction.NEITHER:
			finalphys = attractflags.ACE
		elif physattract == attraction.BI:
			finalphys = attractflags.BI
		elif physattract == attraction.PAN:
			finalphys = attractflags.PAN

func getromattr() -> void:
	if finalgender == finalgenderlist.MALE:
		if romattract == attraction.MALE:
			finalrom = attractflags.GAY
		elif romattract == attraction.FEMALE:
			finalrom = attractflags.HET
		elif romattract == attraction.NEITHER:
			finalrom = attractflags.ARO
		elif romattract == attraction.BI:
			finalrom = attractflags.BI
		elif romattract == attraction.PAN:
			finalrom = attractflags.PAN
	if finalgender == finalgenderlist.FEMALE:
		if romattract == attraction.MALE:
			finalrom = attractflags.HET
		elif romattract == attraction.FEMALE:
			finalrom = attractflags.LESBIAN
		elif romattract == attraction.NEITHER:
			finalrom = attractflags.ARO
		elif romattract == attraction.BI:
			finalrom = attractflags.BI
		elif romattract == attraction.PAN:
			finalrom = attractflags.PAN
	if finalgender == finalgenderlist.NONBINARY:
		if romattract == attraction.MALE:
			finalrom = attractflags.ACHILEAN
		elif romattract == attraction.FEMALE:
			finalrom = attractflags.SAPPHIC
		elif romattract == attraction.NEITHER:
			finalrom = attractflags.ARO
		elif romattract == attraction.BI:
			finalrom = attractflags.BI
		elif romattract == attraction.PAN:
			finalrom = attractflags.PAN
	if finalgender == finalgenderlist.AGENDER:
		if romattract == attraction.MALE:
			finalrom = attractflags.ACHILEAN
		elif romattract == attraction.FEMALE:
			finalrom = attractflags.SAPPHIC
		elif romattract == attraction.NEITHER:
			finalrom = attractflags.ARO
		elif romattract == attraction.BI:
			finalrom = attractflags.BI
		elif romattract == attraction.PAN:
			finalrom = attractflags.PAN
#this is what creates the horse, their attributes are randomized and they play the cry sound
func _ready() -> void:
	saved_scale = scale
	cry_sound_player.play()
	
	agab = randi_range(0, 1)
	genderid = randi_range(0, 5)
	romattract = randi_range(0, 4)
	physattract = randi_range(0, 4)
	
	getgender()
	getphysattr()
	getromattr()
	
	cry_sound_player.play()
	
	set_appearance()
	target_position = position
	current_basis = basis
	target_basis = basis
	reset_hop_timer()
#translates the data of their attributes into a physical appearance
func set_appearance() -> void:
	if not mesh_instance:
		return
	if mane_materials.size() > 0:
		var mane_index = clampi(finalphys, 0, mane_materials.size() - 1)
		mesh_instance.set_surface_override_material(mane_surface_index, mane_materials[mane_index])
	if tail_materials.size() > 0:
		var tail_index = clampi(finalrom, 0, tail_materials.size() - 1)
		mesh_instance.set_surface_override_material(tail_surface_index, tail_materials[tail_index])
	if horn_materials.size() > 0:
		var horn_index = clampi(genderid, 0, horn_materials.size() - 1)
		mesh_instance.set_surface_override_material(horn_surface_index, horn_materials[horn_index])
	if eye_materials.size() > 0:
		var eye_index = clampi(agab, 0, eye_materials.size() - 1)
		mesh_instance.set_surface_override_material(eye_surface_index, eye_materials[eye_index])
#tells the horse to hop and rotate itself accordingly on a timer
func _process(delta: float) -> void:
	hop_timer += delta
	
	if not is_hopping and hop_timer >= next_hop_time:
		start_hop()

	if is_hopping:
		hop_progress += delta * 3.5
		
		# Smoothly interpolate rotation and reapply saved scale so it doesn't resquish
		current_basis = current_basis.slerp(target_basis, delta * 12.0)
		basis = current_basis
		scale = saved_scale
		
		if hop_progress >= 1.0:
			hop_progress = 1.0
			is_hopping = false
			position = target_position
			reset_hop_timer()
		else:
			var current_pos = start_position.lerp(target_position, hop_progress)
			current_pos.y += sin(hop_progress * PI) * jump_height
			position = current_pos
#the actual process of hopping
func start_hop() -> void:
	is_hopping = true
	hop_progress = 0.0
	hop_timer = 0.0
	start_position = position
	
	hop_sound_player.pitch_scale = randf_range(0.5, 1.5)
	hop_sound_player.play()
	
	var angle = randf() * TAU
	var dist = randf() * hop_range
	var offset = Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	target_position = start_position + offset
	
	if target_position.length() > bounds_radius:
		target_position = target_position.normalized() * bounds_radius
		
	var look_dir = target_position - start_position
	look_dir.y = 0.0
	
	if look_dir.length_squared() > 0.001:
		current_basis = basis
		target_basis = Basis.looking_at(look_dir.normalized(), Vector3.UP).rotated(Vector3.UP, PI)
#sets a random amount of time until the next one
func reset_hop_timer() -> void:
	next_hop_time = randf_range(hop_interval_min, hop_interval_max)
