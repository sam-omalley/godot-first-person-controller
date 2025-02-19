extends Node3D

@onready var gun_anim: AnimationPlayer = $AnimationPlayer
@onready var gun_barrel: RayCast3D = $RayCast3D

# Bullets
var bullet = load("res://scenes/bullet.tscn")
var instance

func shoot(node_parent, bullet_position, bullet_basis):
	if not gun_anim.is_playing():
		gun_anim.play('Shoot')
		instance = bullet.instantiate()
		instance.position = bullet_position
		instance.transform.basis = bullet_basis
		
		node_parent.add_child(instance)
