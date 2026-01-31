extends Node

func load_map(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var lines = content.split('\n');
	
	var types_start
	var types_end
	var map_start
	var map_end
	var properties = []
	for i in range(0, lines.size()):
		var line = lines[i]
		line = replace_regex(line, r'\/\/.*', "") # remove comments
		line = replace_regex(line, r'[ \t]', "") # remove whitespace
		lines[i] = line
		
		match line:
			"types:": types_start = i + 1
			"/types": types_end = i
			"map:": map_start = i + 1
			"/map": map_end = i
			"": continue
			_: properties.append(i)
		
	
	var types = {}
	for i in range(types_start, types_end):
		var line = split_regex(lines[i], r'=')
		if !line[0].is_valid_int():
			print("ERROR: non number value in map")
		else:
			types[line[0].to_int()] = line[1]
	
	var map = []
	for i in range(map_start, map_end):
		var line = lines[i].bigrams()
		map.append([])
		var y = i - map_start
		for x in range(0, line.size()):
			var tile = line[x]
			if x % 2 == 0:
				if !tile.is_valid_int():
					print("ERROR: non number value in map")
				else:
					map[y].append(tile.to_int())
	
	var player
	var collidable
	for i in properties:
		if range(types_start, types_end).has(i) || range(map_start, map_end).has(i): continue
		var line = lines[i].split(":")
		match line[0]:
			"player": player = line[1].to_int()
			"collidable": collidable = array_to_int(line[1].split(","))
			_: print("Property %s not defined" % line[0])
	
	return {
		"map": map,
		"types": types,
		"player": player,
		"collidable": collidable,
	}

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
	for x in range(0, arr.size()):
		var item = arr[x]
		if !item.is_valid_int():
			print("ERROR: non number value")
		else:
			output.append(item.to_int())
	return output
