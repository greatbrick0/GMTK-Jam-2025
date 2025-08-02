extends Node3D

@export var maxLifespan: float = 3.0
var lifespan: float = 0.0
@export var explosionSoundFrequency: float = 0.2
@export var explosionSoundMax: int = 8
var nextExplosionSound: int = 0

func _ready() -> void:
	$TestSmoke1/GPUParticles3D.emitting = true

func _process(delta) -> void:
	lifespan += 1.0 * delta
	
	if(nextExplosionSound < explosionSoundMax):
		if(lifespan > explosionSoundFrequency * nextExplosionSound):
			nextExplosionSound += 1
			$ExplosionSound.play()
	
	if(lifespan >= maxLifespan):
		queue_free()
