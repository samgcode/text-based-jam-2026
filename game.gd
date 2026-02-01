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
var interactable;
var dialogs;

var player_pos = Vector2(5, 5)
var camera_target = player_pos * 64 + Vector2(32, 32)
var facing_dir = Vector2(0, 0)
var current_dialog = []
var in_dialog = false
var dialog_index = 0

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
	interactable = map_data["interactable"]
	dialogs = map_data["dialog"]
	
	map[player_pos.y][player_pos.x] = player
	
	update_map()
	update_facing()
	$DialogBox.hide()
	$Camera.position = camera_target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Camera.position = lerp($Camera.position, camera_target, camera_smoothing)
	if in_dialog:
		if Input.is_action_just_pressed(ACTION1):
			next_dialog()
			return
	else:
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

func update_player():
	var target_pos = player_pos + facing_dir
	var target_tile = map[target_pos.y][target_pos.x]
	if walkable(target_tile):
		map[player_pos.y][player_pos.x] = init_map[player_pos.y][player_pos.x]
		player_pos = target_pos
		map[player_pos.y][player_pos.x] = player
		camera_target = player_pos * 64 + Vector2(32, 32)
		update_map()
		update_facing()
		print(player_pos)
	if interactable.has(target_tile):
		in_dialog = true
		current_dialog = dialogs[target_pos]
		dialog_index = -1
		$DialogBox.position = (target_pos + Vector2(1, -1)) * 64
		$DialogBox.show()
		next_dialog()

func update_facing():
	if facing_dir == Vector2.ZERO: 
		$FacingLabel.text = ""
		return
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
	if interactable.has(target_tile): indicator = "toki"
	elif collidable.has(target_tile): indicator = "ala"
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

func next_dialog():
	dialog_index += 1
	if dialog_index >= current_dialog.size():
		in_dialog = false
		current_dialog = []
		$DialogBox.hide()
		return
	$DialogBox/Dialog.text = current_dialog[dialog_index]

func radians(deg: float) -> float:
	return deg * PI/180

func walkable(tile: int):
	return !(collidable.has(tile) || interactable.has(tile))
