extends Node

func _ready():
	var dict_resource = DictionaryResource.new()
	
	var file_eng = FileAccess.open("res://dictionary.txt", FileAccess.READ)
	if file_eng:
		var content = file_eng.get_as_text().strip_edges().to_upper()
		for word in content.split("\n"):
			var clean_word = word.strip_edges().replace('"','')
			if clean_word != "":
				dict_resource.english_words.append(clean_word)
		file_eng.close()

	var file_prog = FileAccess.open("res://dictionary_prog.txt", FileAccess.READ)
	if file_prog:
		while not file_prog.eof_reached():
			var line = file_prog.get_line().strip_edges()
			if line.is_empty():
				continue
			var comma_split = line.find(",")
			if comma_split != -1:
				var word = line.substr(0, comma_split).strip_edges().trim_prefix('"').trim_suffix('"')
				var definition = line.substr(comma_split + 1).strip_edges().trim_prefix('"').trim_suffix('"')
				dict_resource.programming_words[word] = definition
		file_prog.close()

	ResourceSaver.save(dict_resource, "res://dictionary_resource.tres")
	print("Dictionaries saved as .tres")
