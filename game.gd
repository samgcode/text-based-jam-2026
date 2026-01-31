extends Node2D

@export
var camera_smoothing: float = 0.03

const UP = "up"
const DOWN = "down"
const LEFT = "left"
const RIGHT = "right"
const ACTION1 = "action1"

const FACING = "  |%s|  \n%s|  |%s\n  |%s|  "

const visible_radius = Vector2(13, 8);

var types = {}

var init_map;
var map;
var map_height;
var map_width;

var player;
var collidable;

var player_pos: Vector2 = Vector2(2, 2)
var camera_target: Vector2 = Vector2(128, 128)
var facing_dir: Vector2 = Vector2(0, 0)

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
	
	$FacingLabel.text = FACING
	update_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var input_dir = Vector2.ZERO
	if Input.is_action_just_pressed(UP): input_dir.y = -1
	if Input.is_action_just_pressed(DOWN): input_dir.y = 1
	if Input.is_action_just_pressed(LEFT): input_dir.x = -1
	if Input.is_action_just_pressed(RIGHT): input_dir.x = 1
	
	if input_dir != Vector2.ZERO:
		facing_dir = input_dir
		update_facing()
	
	if Input.is_action_just_pressed(ACTION1):
		update_player()
	
	$Camera.position = lerp($Camera.position, camera_target, camera_smoothing)

func update_player():
	map[player_pos.y][player_pos.x] = init_map[player_pos.y][player_pos.x]
	player_pos += facing_dir
	if collidable.has(map[player_pos.y][player_pos.x]):
		player_pos -= facing_dir
	camera_target = player_pos * 64 + Vector2(32, 32)
	map[player_pos.y][player_pos.x] = player
	update_map()
	update_facing()

func update_facing():
	var target_tile = map[player_pos.y+facing_dir.y][player_pos.x+facing_dir.x]
	var replacement = ["  ", "  ", "  ", "  "]
	var angles = [180, 90, -90, 0]
	var dir = 0;
	
	if facing_dir.y == 1: dir = 3
	elif facing_dir.y == -1: dir = 0
	elif facing_dir.x == 1: dir = 2
	elif facing_dir.x == -1: dir = 1
	
	$FacingLabel.rotation = 0
	var indicator = ""
	if collidable.has(target_tile): indicator = "ala"
	else:
		indicator = "ni"
		$FacingLabel.rotation = radians(angles[dir])
		dir = 3
	
	replacement[dir] = indicator
	$FacingLabel.text = FACING % replacement

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
	$FacingLabel.position = camera_target - Vector2.ONE * 64

func radians(deg: float) -> float:
	return deg * PI/180
