extends Node3D

@export var speed: float = 40.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D


func _process(delta: float) -> void:
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true

		if ray.get_collider():
			if ray.get_collider().get_parent().is_in_group('BodyParts'):
				ray.get_collider().hit()
				ray.enabled = false

		await get_tree().create_timer(1.0).timeout
		queue_free()
	position += transform.basis * Vector3.FORWARD * speed * delta



func _on_lifetime_timeout() -> void:
	queue_free()
