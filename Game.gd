extends Control

var vowels := ['A', 'E', 'I', 'O', 'U']
var consonants := ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 
					'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']
var player_hand := []
var dictionary := []

@onready var letters_container = $VBoxContainer/LettersContainer
@onready var score_label = $VBoxContainer/ScoreLabel

#INITIAL
func _ready():
	draw_initial_hand()
	update_display()
	load_dictionary()
	print(dictionary.slice(0, 10))  # Prints the first 10 entries


func draw_initial_hand():
	for i in range(10):
		if i % 2 == 0:
			player_hand.append(vowels.pick_random())
		else:
			player_hand.append(consonants.pick_random())

# Update UI
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
	print("Word inputted: ", word)
	if word.length() < 3:
		print("Word too short.")
		return false
	if not dictionary.has(word):
		print("Word not found.")
		return false

	var temp_hand = player_hand.duplicate()
	print(player_hand)
	for letter in word:
		if letter in temp_hand:
			temp_hand.erase(letter)
		else:
			print("Letter missing:", letter)
			return false
	return true

func draw_letters():
	if player_hand.size() >= 20:
		return

	for i in range(2):#draw 2 letters; IMPORTANT: vowels first
		if player_hand.size() < 20:
			player_hand.append(vowels.pick_random())
		if player_hand.size() < 20:
			player_hand.append(consonants.pick_random())

	update_display()

func on_word_submitted():
	var input_word = $VBoxContainer/WordInput.text.to_upper()
	if is_word_valid(input_word):
		$VBoxContainer/FeedbackLabel.text = "✅ Word Accepted!"
		remove_used_letters(input_word)
		draw_letters()
	else:
		$VBoxContainer/FeedbackLabel.text = "❌ Invalid Word!"
	update_display()
	$VBoxContainer/WordInput.text = ""

func remove_used_letters(word: String):
	for letter in word:
		player_hand.erase(letter)
