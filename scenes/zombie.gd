extends CharacterBody3D

var player = null
var state_machine

@export var speed: float = 4.0
@export var attack_range: float = 2.5
@export var player_path : NodePath

@onready var nav_agent: NavigationAgent3D = %NavigationAgent3D
@onready var anim_tree : AnimationTree = %AnimationTree

func _ready() -> void:
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func _process(_delta: float) -> void:
	velocity = Vector3.ZERO

	var look_vec: Vector3
	match state_machine.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * speed

			look_vec = global_position + velocity
		"Attack":
			look_vec = player.global_position
			look_vec.y = global_position.y

	look_at(look_vec, Vector3.UP)



	
	anim_tree.set("parameters/conditions/attack", _target_in_range())

	move_and_slide()

func _target_in_range() -> bool:
	return global_position.distance_to(player.global_position) <= attack_range
	