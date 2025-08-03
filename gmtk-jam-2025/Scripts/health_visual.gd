extends Node3D


@export var colourHurt: Color = Color(1,1,1,1)

@export var colourHealthy: Color = Color(1,1,1,1)

func _setup(maxHealth: int):
	
	var pip_scene = preload("res://Scenes/VFXScene/Health_Pip.tscn")
	
	#create pip amount
	for ii in range (maxHealth):
		var pip_instance = pip_scene.instantiate()
		$Pips_Container.add_child(pip_instance)
		
		#move pip to correct location.
		#pip 1 always leftmost.
		pip_instance.translate((Vector3.LEFT * 0.5) * 0.5 * ((float(maxHealth) / 2.0) - ii) )
		
		$Timer.start()



func _getPip(index) -> Sprite3D:
	var sprite = $Pips_Container.get_child(index).get_child(0)
	
	if sprite is Sprite3D:
		return sprite
	else:
		return null
	
func _updatePip(pip, hurt: bool):
		if pip.material_override:
			pip.material_override = pip.material_override.duplicate()
		pip.material_override.set_shader_parameter("Colour", colourHurt if hurt else colourHealthy)

func _showPips(show): 
	for item in $Pips_Container.get_children():
		if show:
			item.visible = true
		else:
			item.visible = false

func _UpdateHealth(health :int, funni):
	_showPips(true)
	print(health)
	
	for ii in range ($Pips_Container.get_child_count()):
		if (ii <= health -1):
			print("Pip ", ii, " hurt: ", ii >= health)
			_updatePip(_getPip(ii),false) #unhurt case
		else:
			print("Pip ", ii, " hurt: ", ii >= health)
			_updatePip(_getPip(ii),true) #hurt case
	
	$Timer.start()
	


func _on_timer_timeout():
	_showPips(false)
