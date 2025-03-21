extends Control

var vowels := ['A', 'E', 'I', 'O', 'U']
var consonants := ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']
var letters_all := []
var player_hand := []
var dictionary := []
var dictionary_prog := {}
var score := 0
var lives := 3
var reaction := 0
var letter_points := {
	'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1,
	'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8,
	'K': 5, 'L': 1, 'M': 3, 'N': 1, 'O': 1,
	'P': 3, 'Q': 10, 'R': 1, 'S': 1, 'T': 1,
	'U': 1, 'V': 4, 'W': 4, 'X': 8, 'Y': 4,
	'Z': 10
}

@onready var letters_container = $VBoxContainer/LettersContainer
@onready var score_label = $VBoxContainer/ScoreLabel
@onready var lives_container = $LivesContainer
@onready var reaction_image = $ReactionImage
@export var reaction_texture: Array[Texture2D]
@export var heart_texture: Texture2D
@export var key_button: Dictionary = {}

#INITIAL
func _ready():
	letters_all = vowels + consonants
	draw_initial_hand()
	update_text_display()
	load_dictionary()
	update_lives_asset()
	var keyboard = get_node("/root/Main/KeyboardControl")
	keyboard.key_press.connect(on_virtual_kbd_pressed)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			on_word_submitted()

func setup_lives_display():
	lives_container.clear_children()
	for i in range(3):
		var heart_texture = TextureRect.new()
		heart_texture.texture = load("res://assets/heart64.png")
		heart_texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		heart_texture.custom_minimum_size = Vector2(64,64)
		lives_container.add_child(heart_texture)

func game_over():
	$VBoxContainer/FeedbackLabel.text = "💀 Skill Issue! 🗿 Final Score: %d" % score
	$VBoxContainer/SubmitButton.disabled = true
	$VBoxContainer/WordInput.editable = false

# Letters
func draw_initial_hand():
	#for i in range(10):
		#if i % 3 == 0:
			#player_hand.append(vowels.pick_random())
		#else:
			#player_hand.append(consonants.pick_random())
	letters_all.shuffle()
	while player_hand.size() < 10 and letters_all.size() > 0:
		var letter = letters_all.pop_back()
		player_hand.append(letter)
	update_text_display()

func draw_letters():
	letters_all.shuffle
	vowels.shuffle()
	var vowel_count = player_hand.count(func(l): vowels.has(l))

	for i in range(4):
		if player_hand.size() >= 10:
			break
		if vowel_count < 2:
			var letter = vowels.pop_back()
			if not player_hand.has(letter):
				player_hand.append(letter)
				vowel_count += 1
		elif letters_all.size() > 0:
			var letter = letters_all.pop_back()
			if not player_hand.has(letter):
				player_hand.append(letter)
	
	#if player_hand.size() >= 10:
		#return
#
	#for i in range(2): # draw 2 letters; IMPORTANT: vowels first
		#if player_hand.size() < 20:
			#player_hand.append(vowels.pick_random())
		#if player_hand.size() < 20:
			#player_hand.append(consonants.pick_random())
	update_text_display()

func remove_used_letters(word: String):
	for letter in word:
		player_hand.erase(letter)
		if not vowels.has(letter):
			vowels.append(letter)
		elif not letters_all.has(letter):
			letters_all.append(letter)

	letters_all.shuffle()
	vowels.shuffle()
# Letters

# Update UI
func update_lives_asset():
	for child in lives_container.get_children():
		child.queue_free()
	
	for i in range (lives):
		var heart_icon = TextureRect.new()
		heart_icon.texture = heart_texture
		heart_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lives_container.add_child(heart_icon)

func update_reaction_asset():
	if reaction >= 0 and reaction < reaction_texture.size():
		reaction_image.texture = reaction_texture[reaction]

func update_text_display():
	for child in letters_container.get_children():
		child.queue_free()
	
	for letter in player_hand:
		var letter_label = Label.new()
		letter_label.text = letter
		letters_container.add_child(letter_label)
# Update UI

func load_dictionary():
	var file_eng = FileAccess.open("res://assets/dictionary.txt", FileAccess.READ)
	if file_eng:
		var content = file_eng.get_as_text().strip_edges().to_upper()
		for word in content.split("\n"):
			var clean_word = word.strip_edges().replace('"','')
			if clean_word != "":
				dictionary.append(clean_word)
		print("Dictionary loaded with %d words" % dictionary.size())
	
	var file_prog = FileAccess.open("res://assets/dictionary_prog.txt", FileAccess.READ)
	if file_prog:
		while not file_prog.eof_reached():
			var line = file_prog.get_line().strip_edges()
			if line.is_empty():
				continue
			var comma_split = line.find(",")
			if comma_split != -1:
				var word = line.substr(0, comma_split).strip_edges().trim_prefix('"').trim_suffix('"')
				var definition = line.substr(comma_split + 1).strip_edges().trim_prefix('"').trim_suffix('"')
				dictionary_prog[word] = definition
		#var content = file_prog.get_as_text().strip_edges().to_upper()
		#for word in content.split(","):
			#var clean_word = word.strip_edges()
			#if clean_word != "":
				#dictionary_prog.append(clean_word)
		print("Dictionary (Prog) loaded with %d words" % dictionary_prog.size())
	print(dictionary_prog) #debug

func is_word_valid(word: String) -> bool:
	if word.length() < 3:
		return false
	if dictionary_prog.has(word.to_lower()):
		return true
	if not dictionary.has(word):
		return false

	var temp_hand := player_hand.duplicate()
	for letter in word:
		if letter in temp_hand:
			#temp_hand.erase(letter)
			continue
		else:
			return false
	return true

# Buttons
func on_virtual_kbd_pressed(key_letter: String):
	var letter = key_letter.replace("Button","").to_lower()
	$VBoxContainer/WordInput.text += letter;

func on_word_submitted():
	var input_word = $VBoxContainer/WordInput.text.to_upper()
	if is_word_valid(input_word):
		if dictionary_prog.has(input_word.to_lower()):
			$VBoxContainer/FeedbackLabel.text = "🎉 Proggers! Score doubled and lives restored!"
			reaction = 1;
			lives = 3;
			update_lives_asset()
		else:
			$VBoxContainer/FeedbackLabel.text = "✅ Word accepted but is not Proggers! -1 Heart!"
			reaction = 0;
			lives -= 1;
			update_lives_asset()
		
		var word_score = calculate_score(input_word)
		if dictionary_prog.has(input_word.to_lower()):
			word_score *= 2
		score += word_score
		score_label.text = "Score: %d" % score
		remove_used_letters(input_word)
		draw_letters()
		
		if lives <= 0:
			game_over()
	else:
		$VBoxContainer/FeedbackLabel.text = "❌ Invalid Input! Try checking your letters."
		reaction = 2;
	update_text_display()
	update_reaction_asset()
	$VBoxContainer/WordInput.text = ""
# Button

func calculate_score(word: String) -> int:
	var word_score := 0
	for letter in word:
		word_score += letter_points.get(letter, 0)
		#print("Score added:%d" % word_score + "into %d" % score)
	return word_score
