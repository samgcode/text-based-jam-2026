extends Node2D

@export
var camera_smoothing: float = 0.03

const UP = "up"
const DOWN = "down"
const LEFT = "left"
const RIGHT = "right"

const visible_radius = Vector2(13, 8);

var types = {}

var init_map;
var map;
var map_height;
var map_width;

var player;
var collidable;

var player_pos: Vector2 = Vector2(2, 2)
var camera_target: Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map_data = read_files.load_map("res://map.txt")
	types = map_data["types"]
	init_map = map_data["map"]
	map = init_map.duplicate(true)
	map_height = map.size()
	map_width = map[0].size()
	
	player = map_data["player"]
	collidable = map_data["collidable"]
	
	map[player_pos.y][player_pos.x] = player
	update_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_dir = Vector2(0,0)
	if Input.is_action_just_pressed(UP):
		input_dir.y = -1
	if Input.is_action_just_pressed(DOWN):
		input_dir.y = 1
	if Input.is_action_just_pressed(LEFT):
		input_dir.x = -1
	if Input.is_action_just_pressed(RIGHT):
		input_dir.x = 1
	update_player(input_dir)
	
	$Camera.position = lerp($Camera.position, camera_target, camera_smoothing)

func update_player(input_dir: Vector2):
	map[player_pos.y][player_pos.x] = init_map[player_pos.y][player_pos.x]
	player_pos += input_dir
	if collidable.has(map[player_pos.y][player_pos.x]):
		player_pos -= input_dir
	camera_target = player_pos * 64 + Vector2(32, 32)
	map[player_pos.y][player_pos.x] = player
	update_map()

func update_map():
	var map_text: String = ""
	for row in range(player_pos.y-visible_radius.y, player_pos.y+visible_radius.y):
		for col in range(player_pos.x-visible_radius.x, player_pos.x+visible_radius.x):
			var tile = map[row%map_height][col%map_width]
			if types.has(tile):
				map_text += types[tile]
			else:
				map_text += "seme"
				print("Symbol %s not defined at row %s, col %s" % [tile, row, col])
			map_text += "|"
		map_text += "\n"
	
	$Map.text = map_text
	$Map.position = camera_target - visible_radius*64
