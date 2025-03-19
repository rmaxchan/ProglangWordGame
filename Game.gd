extends Control

var vowels := ['A', 'E', 'I', 'O', 'U']
var consonants := ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 
					'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']
var player_hand := []
var dictionary := []
var score := 0
var lives := 3
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
@onready var lives_label = Label.new()

#INITIAL
func _ready():
	draw_initial_hand()
	update_display()
	load_dictionary()

func setup_lives_display():
	lives_label.text = "Lives: %d" % lives
	$VBoxContainer.add_child(lives_label)

func game_over():
	$VBoxContainer/FeedbackLabel.text = "💀 Skill Issue! 🗿 Final Score: %d" % score
	$VBoxContainer/SubmitButton.disabled = true
	$VBoxContainer/WordInput.editable = false

func draw_initial_hand():
	for i in range(10):
		if i % 2 == 0:
			player_hand.append(vowels.pick_random())
		else:
			player_hand.append(consonants.pick_random())

# Update UI
#TODO: Asset handler
func update_display():
	for child in letters_container.get_children():
		child.queue_free()
	
	for letter in player_hand:
		var letter_label = Label.new()
		letter_label.text = letter
		letters_container.add_child(letter_label)

func load_dictionary():
	var file = FileAccess.open("res://assets/dictionary.txt", FileAccess.READ)
	if file:
		var content = file.get_as_text().strip_edges().to_upper()
		for word in content.split(","):
			var clean_word = word.strip_edges()
			if clean_word != "":
				dictionary.append(clean_word)
		print("Dictionary loaded with %d words" % dictionary.size())

func is_word_valid(word: String) -> bool:
	if word.length() < 3:
		return false
	if not dictionary.has(word):
		return false

	var temp_hand = player_hand.duplicate()
	print(player_hand)
	for letter in word:
		if letter in temp_hand:
			temp_hand.erase(letter)
		else:
			return false
	return true

func draw_letters():
	if player_hand.size() >= 20:
		return

	for i in range(2): # draw 2 letters; IMPORTANT: vowels first
		if player_hand.size() < 20:
			player_hand.append(vowels.pick_random())
		if player_hand.size() < 20:
			player_hand.append(consonants.pick_random())
	#TODO: balance?

	update_display()

func on_word_submitted():
	var input_word = $VBoxContainer/WordInput.text.to_upper()
	if is_word_valid(input_word):
		var word_score = calculate_score(input_word)
		score += word_score
		score_label.text = "Score: %d" % score
		$VBoxContainer/FeedbackLabel.text = "✅ Word Accepted!"
		remove_used_letters(input_word)
		draw_letters()
	else:
		lives -= 1
		lives_label.text = "Lives: %d" % lives
		$VBoxContainer/FeedbackLabel.text = "❌ Invalid Word!"
		if lives <= 0:
			game_over()
	update_display()
	$VBoxContainer/WordInput.text = ""

func remove_used_letters(word: String):
	for letter in word:
		player_hand.erase(letter)

func calculate_score(word: String) -> int:
	var word_score := 0
	for letter in word:
		word_score += letter_points.get(letter, 0)
		print("Score added:%d" % word_score + "into %d" % score)
		#TODO: proglang multiplier + debugging
	return word_score
