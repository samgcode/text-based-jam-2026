extends Node

func load_map(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var lines = content.split('\n');
	
	var map_data = {
		"map": [],
		"types": {},
		"player": 0,
		"collidable": [],
		"interactable": [],
		"dialog": {}
	}
	
	var types = false
	var map = false
	var map_start = 0;
	var dialog = false
	var current_dialog = Vector2.ZERO
	for i in range(0, lines.size()):
		var line = lines[i]
		line = replace_regex(line, r'\/\/.*', "") # remove comments
		line = replace_regex(line, r'[ \t]', "") # remove whitespace
		lines[i] = line
		var in_section = types || map || dialog
		
		match line:
			"": continue
			"types:": types = true; continue
			"/types": types = false; continue
			"map:": map = true; map_start = i + 1; continue
			"/map": map = false; continue
			"/dialog": dialog = false; continue
			_:
				if !in_section:
					var property = lines[i].split(":")
					match property[0]:
						"player":
							map_data["player"] = property[1].to_int()
						"collidable":
							map_data["collidable"] = array_to_int(property[1].split(","))
						"interactable":
							map_data["interactable"] = array_to_int(property[1].split(","))
						"dialog": 
							dialog = true
							current_dialog = array_to_vec2(property[1].split("),("))[0]
							map_data["dialog"][current_dialog] = []
						_: error("Property %s not defined" % property[0], i)
					continue
		
		if types:
			var tline = split_regex(lines[i], r'=')
			if !tline[0].is_valid_int():
				error("non number value in types", i)
			else:
				map_data["types"][tline[0].to_int()] = tline[1]
		elif map:
			var row = line.bigrams()
			map_data["map"].append([])
			var y = i - map_start
			for x in range(0, row.size()):
				var tile = row[x]
				if x % 2 == 0:
					if !tile.is_valid_int():
						error("non number value in map", i)
					else:
						map_data["map"][y].append(tile.to_int())
		elif dialog:
			map_data["dialog"][current_dialog].append(line)
		else:
			error("no handling for line", i)
	
	print(map_data)
	return map_data

# https://regexr.com/ (use PCRE engine)
func replace_regex(string: String, regex: String, replacement: String) -> String:
	var regex_ = RegEx.create_from_string(regex)
	var string_ = string
	for result in regex_.search_all(string):
		string_ = string_.replace(result.get_string(), replacement)
	return string_

func split_regex(string: String, regex: String) -> Array:
	var string_ = replace_regex(string, regex, 'ඞ')
	return string_.split('ඞ')

func array_to_int(arr: Array[String]) -> Array:
	var output = []
	for item in arr:
		if !item.is_valid_int():
			print("ERROR: non number value")
		else:
			output.append(item.to_int())
	return output

func array_to_vec2(arr: Array[String]) -> Array:
	var output = []
	for x in range(0, arr.size()):
		var item = replace_regex(arr[x], "[()]", "").split(",")
		if !item[0].is_valid_int() || !item[1].is_valid_int():
			print("ERROR: non number value")
		else:
			output.append(Vector2(item[0].to_int(), item[1].to_int()))
		
	return output

func error(msg: String, line: int):
	print('ERROR: %s at line %s' % [msg, line])
