extends SceneTree

func _init() -> void:
	var output_path := "res://build/ios_project/godot_apple_embedded/godot_apple_embedded.pck"
	var packer := PCKPacker.new()
	var err := packer.pck_start(output_path)
	if err != OK:
		push_error("Could not start PCK: %s" % err)
		quit(1)
		return

	for path in [
			"res://project.godot",
			"res://scenes/main.tscn",
			"res://src/main.gd",
			"res://assets/icon.svg",
			"res://assets/fonts/ArialUnicode.ttf.import",
			"res://assets/fonts/ArialUnicode.ttf"
		]:
		err = packer.add_file(path, ProjectSettings.globalize_path(path))
		if err != OK:
			push_error("Could not add %s: %s" % [path, err])
			quit(1)
			return

	err = packer.flush(true)
	if err != OK:
		push_error("Could not finish PCK: %s" % err)
		quit(1)
		return

	print("Packed ", output_path)
	quit()
