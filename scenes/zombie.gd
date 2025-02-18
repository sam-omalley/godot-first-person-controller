extends CharacterBody3D

var player = null
var state_machine

@export var speed: float = 4.0
@export var attack_range: float = 2.5
@export var detect_range: float = 8.0 
@export var player_path : NodePath
@export var turn_speed : float = 5.0

@onready var nav_agent: NavigationAgent3D = %NavigationAgent3D
@onready var anim_tree : AnimationTree = %AnimationTree

var health = 6

func _ready() -> void:
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	visible = false
	anim_tree.set("parameters/conditions/alive", false)

	var body_parts = $Armature/Skeleton3D.get_children()
	for b in body_parts:
		if b.is_in_group('BodyParts'):
			var area = b.get_node('Area3D')
			area.body_part_hit.connect(_on_body_part_hit)

func _process(delta: float) -> void:
	velocity = Vector3.ZERO

	match state_machine.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * speed

			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * turn_speed)
		"Attack":
			var look_vec: Vector3 = player.global_position
			look_vec.y = global_position.y
			look_at(look_vec)
		"Stand Up":
			var look_vec: Vector3 = player.global_position
			look_vec.y = global_position.y
			look_at(look_vec, Vector3.UP)

	
	anim_tree.set("parameters/conditions/attack", _target_in_range(attack_range))
	
	if _target_in_range(detect_range):
		anim_tree.set("parameters/conditions/alive", true)

	move_and_slide()

func _target_in_range(distance: float) -> bool:
	return global_position.distance_to(player.global_position) <= distance
	

func _hit_finished():
	if global_position.distance_to(player.global_position) < attack_range + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func _on_body_part_hit(damage) -> void:
	health -= damage

	if health <= 0:
		queue_free()