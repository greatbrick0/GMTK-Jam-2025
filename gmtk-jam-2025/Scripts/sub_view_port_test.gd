@tool
extends Node2D

@export_tool_button("Generate", "Add") var generate_button = generate_icons
@export var iconName: String = ""
const OUTPUT_DIR := "res://Art/Images/Generated Icons/"
const ICON_SIZE := Vector2i(256, 256)

func generate_icons():
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(OUTPUT_DIR):
		dir.make_dir_recursive(OUTPUT_DIR)
	
	var icon_image
	icon_image = await render_character_to_image()
	if icon_image:
		var file_name = iconName + ".png"
		var output_path = OUTPUT_DIR + file_name
		icon_image.save_png(output_path)
		print("Saved icon to: ", output_path)


func render_character_to_image() -> Image:
	var sub_viewport: SubViewport = $SubViewport
	var camera: Camera3D = $SubViewport/Camera3D
	var light: DirectionalLight3D = $SubViewport/DirectionalLight3D
	
	await get_tree().process_frame
	var tex := sub_viewport.get_texture()
	var image := tex.get_image()
	image.convert(Image.FORMAT_RGBA8)
	
	return image
