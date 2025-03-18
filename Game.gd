extends Control

var vowels := ['A', 'E', 'I', 'O', 'U']
var consonants := ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 
					'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']
var player_hand := []

@onready var letters_container = $VBoxContainer/LettersContainer
@onready var score_label = $VBoxContainer/ScoreLabel

#INITIAL
func _ready():
	draw_initial_hand()
	update_display()

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
	draw_letters()
