extends Control

var vowels := ['A', 'E', 'I', 'O', 'U']
var vowels_master := ['A', 'E', 'I', 'O', 'U']
var consonants := ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']
var consonants_master := ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z']
var letters_all := []
var player_hand := []
var dictionary := []
var dictionary_prog := {}
var score := 0
var coins := 0
var coins_goal := 20

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
var letter_textures := {}
var turn_count := 0
const SHOP_INTERVAL := 2

@onready var letters_container = $LettersContainer
@onready var score_label = $InputContainer/ScoreLabel
@onready var lives_container = $LivesContainer
@onready var reaction_image = $ReactionImage
@onready var last_word_label = $DefContainer/LastWordLabel
@onready var definition_label = $DefContainer/DefinitionLabel
@onready var turn_count_label = $TurnCountContainer/TurnCount
@onready var gg_button = $GGButton
@onready var shop_button = $ShopButton
@onready var shop_panel = $ShopButton/ShopPanel
@onready var coins_label = $CoinLabel
@onready var coin_anim = $CoinSprite

@export var reaction_texture: Array[Texture2D]
@export var heart_texture: Texture2D
@export var key_button: Dictionary = {}

# INITIAL
func _ready():
	var keyboard = get_node("/root/Main/KeyboardControl")
	keyboard.key_press.connect(on_virtual_kbd_pressed)
	coin_anim.play("Spin")
	
	letters_all = vowels + consonants
	load_letter_textures()
	draw_initial_hand()
	load_dictionary()
	update_lives_asset()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			on_word_submitted()
# INITIAL

# Letters
func draw_initial_hand():
	#for i in range(10):
		#if i % 3 == 0:
			#player_hand.append(vowels.pick_random())
		#else:
			#player_hand.append(consonants.pick_random())
	
	var vowels_drawn = []

	while vowels_drawn.size() < 3 and vowels.size() > 0:
		vowels.shuffle()
		var vowel = vowels.pop_back()
		vowels_drawn.append(vowel)
	while player_hand.size() + vowels_drawn.size() < 10 and letters_all.size() > 0:
		consonants.shuffle()
		var cons = consonants.pop_back()
		player_hand.append(cons)

	player_hand.append_array(vowels_drawn)
	player_hand.shuffle()
	update_text_display()

func draw_letters():
	vowels = vowels_master.duplicate()
	consonants = consonants_master.duplicate()
	letters_all = vowels + consonants
	var vowel_count = player_hand.count(func(l): vowels.has(l))
	var letters_drawn = 0
	
	while letters_drawn < 4:
		if player_hand.size() >= 10:
			break
		if vowel_count < 2 and vowels.size() > 0:
			vowels.shuffle()
			var letter = vowels.pop_back()
			if not player_hand.has(letter):
				player_hand.append(letter)
				letters_drawn += 1
				vowel_count += 1
				continue
		elif letters_all.size() > 0:
			letters_all.shuffle()
			var letter = letters_all.pop_back()
			if not player_hand.has(letter):
				player_hand.append(letter)
				letters_drawn += 1
		else:
			break
	
	update_text_display()

func remove_used_letters(word: String):
	for letter in word:
		player_hand.erase(letter)
		#if not vowels.has(letter):
			#vowels.append(letter)
		#elif not letters_all.has(letter):
			#letters_all.append(letter)
#
	#letters_all.shuffle()
	#vowels.shuffle()
	#print(vowels)
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
		if letter_textures.has(letter):
			var letter_texture = TextureRect.new()
			letter_texture.texture = letter_textures[letter.to_upper()]
			letter_texture.custom_minimum_size = Vector2(15, 15)
			letters_container.add_child(letter_texture)
		else:
			print("Texture not found for letter: %s" % letter)

func update_last_word_display(input_word: String):
	if dictionary_prog.has(input_word):
		definition_label.text = "Definition: %s" % dictionary_prog[input_word]
		#print("Definition found!")
	else:
		definition_label.text = ""
	definition_label.queue_redraw()
# Update UI

# Load Assets
func load_dictionary():
	var file_eng = FileAccess.open("res://assets/dictionary.txt", FileAccess.READ)
	if file_eng:
		var content = file_eng.get_as_text().strip_edges().to_upper()
		for word in content.split("\n"):
			var clean_word = word.strip_edges().replace('"','')
			if clean_word != "":
				dictionary.append(clean_word)
		print("Dictionary loaded with %d words" % dictionary.size())
		file_eng.close()
	
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
		file_prog.close()
		print("Dictionary (Prog) loaded with %d words" % dictionary_prog.size())
	#print(dictionary_prog) #debug

func load_letter_textures():
	for letter in "+ABCDEFGHIJKLMNOPQRSTUVWXYZ":
		if ResourceLoader.exists("res://assets/letters/" + letter + ".png"):
			#print("Path exists:", ResourceLoader.exists("res://assets/letters/" + letter + ".png"))
			letter_textures[letter] = load("res://assets/letters/" + letter + ".png")
			#print("res://assets/letters/" + letter + ".png added!" )
		else:
			print("Missing textures for %s" %letter)

func setup_lives_display():
	lives_container.clear_children()
	for i in range(3):
		var heart_texture = TextureRect.new()
		heart_texture.texture = load("res://assets/heart64.png")
		heart_texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		heart_texture.custom_minimum_size = Vector2(64,64)
		lives_container.add_child(heart_texture)

# Load Assets

# Game Logic
func is_word_valid(word: String) -> bool:
	if word.length() < 3:
		return false
	var temp_hand := player_hand.duplicate()
	for letter in word:
		if letter in temp_hand:
			#temp_hand.erase(letter)
			continue
		elif "+" in temp_hand:
			#temp_hand.erase("+")
			continue
		else:
			return false
	if dictionary_prog.has(word.to_lower()):
		return true
	if not dictionary.has(word):
		return false
	return true

func calculate_score(word: String) -> int:
	var word_score := 0
	for letter in word:
		word_score += letter_points.get(letter, 0)
		#print("Score added:%d" % word_score + "into %d" % score)
	return word_score

func update_coins():
	if score >= coins_goal:
		coins += 1
		coins_goal += 20
		coins_label.text = "Coins: %d" % coins
# Game Logic

# Buttons
func on_virtual_kbd_pressed(key_letter: String):
	var letter = key_letter.replace("Button","").to_lower()
	$InputContainer/WordInput.text += letter;

func on_word_submitted():
	var input_word = $InputContainer/WordInput.text.to_upper()
	last_word_label.text = "Last input: %s" % input_word
	if is_word_valid(input_word):
		update_shop_countdown()
		enable_shop()
		if dictionary_prog.has(input_word.to_lower()):
			#show_message("🎉 Proggers! Score doubled and lives restored!", 3.0)
			$InputContainer/FeedbackLabel.text = "🎉 Proggers! Score doubled and lives restored!"
			reaction = 1;
			lives = 3;
			update_lives_asset()
		else:
			#show_message("✅ Word accepted but is not Proggers! -1 Heart!",3.0)
			$InputContainer/FeedbackLabel.text = "✅ Word accepted but is not Proggers! -1 Heart!"
			reaction = 0;
			lives -= 1;
			update_lives_asset()
		update_last_word_display(input_word.to_lower())
		
		var word_score = calculate_score(input_word)
		if dictionary_prog.has(input_word.to_lower()):
			word_score *= 2
		score += word_score
		score_label.text = "Score: %d" % score
		update_coins()
		remove_used_letters(input_word)
		draw_letters()
		
		if lives <= 0:
			game_over()
	else:
		#show_message("❌ Invalid Input! Try checking your letters.", 3.0)
		$InputContainer/FeedbackLabel.text = "❌ Invalid Input! Try checking your letters."
		reaction = 2;
	update_text_display()
	update_reaction_asset()
	$InputContainer/WordInput.text = ""

func on_gg_button_pressed():
	game_over()

func on_reset_button_pressed():
	reset_game()

func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
# Button

# End
func game_over():
	#show_message("💀 Skill Issue! 🗿 Final Score: %d" % score, 3.0)
	$InputContainer/FeedbackLabel.text = "💀 Skill Issue! 🗿 Final Score: %d" % score
	reaction = 3
	update_reaction_asset()
	$InputContainer/SubmitButton.disabled = true
	$InputContainer/WordInput.editable = false
	$GGButton.hide()
	$ResetButton.show()

func reset_game():
	score = 0
	lives = 3
	turn_count = 0
	coins = 0
	coins_goal = 20
	#$VBoxContainer/SubmitButton.disabled = false
	#$VBoxContainer/WordInput.editable = true
	score_label.text = "Score: 0"
	get_tree().reload_current_scene()
# End

func _on_shop_button_pressed():
	shop_panel.visible = !shop_panel.visible

func enable_shop():
	shop_button.disabled = true
	if (turn_count != 0):
		if (turn_count % SHOP_INTERVAL == 0):
			shop_button.disabled = false
		else:
			shop_panel.visible = false

func update_shop_countdown():
	turn_count += 1
	var turns_left := SHOP_INTERVAL - (turn_count % SHOP_INTERVAL)
	turn_count_label.text = "Turn left until the shop appears: %s" % turns_left


func _on_add_heart_button_pressed() -> void:
	if(coins >= 2):
		lives = 3
		update_lives_asset()
		coins =- 3
		show_message("You've restored your lives",2.0)
	else: 
		show_message("❗Not Enough Coins❗",2.0)  

func _on_wild_card_pressed() -> void:
	if(coins >= 1):
		player_hand.append("+")
		update_text_display()
		coins =- 3
		show_message("You've activated Wildcard buff",2.0)
	else: 
		show_message("❗Not Enough Coins❗",2.0) 

#letter burst buff
func _on_shuffle_letter_pressed() -> void:
	if(coins >= 3):
		draw_initial_hand()
		coins =- 3
		print("pressed")
		show_message("You've activated Letter Burst buff",2.0)
	else: 
		show_message("❗Not Enough Coins❗",2.0) 

func _on_timer_timeout() -> void:
	$InputContainer/FeedbackLabel.text = ""

func show_message(text: String, duration: float = 2.0):
	$InputContainer/FeedbackLabel.text = text
	$InputContainer/FeedbackLabel.visible = true
	$InputContainer/FeedbackLabel/HideTimer.start(duration)
