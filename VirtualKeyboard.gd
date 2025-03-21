extends Control

var key_map = {}
signal key_press(letter: String)

func _ready():
	for container in [$KBDContainerTop, $KBDContainerMid, $KBDContainerBot]:
		for button in container.get_children():
			var key_letter = button.name.replace("Button", "")
			key_map[key_letter] = button
			button.pressed.connect(on_kbd_key_pressed.bind(key_letter))

func _input(event):
	if event is InputEventKey:
		var letter = OS.get_keycode_string(event.keycode).to_upper()
		if letter in key_map:
			if event.pressed:
				key_map[letter].texture_normal = key_map[letter].texture_pressed
			else:
				key_map[letter].texture_normal = load("res://assets/keyboard/normal/L. Key %d.png" % (event.keycode - KEY_A + 1))

func on_kbd_key_pressed(key_letter: String):
	emit_signal("key_press", key_letter.to_upper())

func animate_key(letter):
	var button = key_map.get(letter)
	if button:
		button.texture_normal = button.texture_pressed
		await get_tree().create_timer(0.1).timeout
		button.texture_normal = button.texture_normal
