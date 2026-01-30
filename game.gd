extends Node2D

const UP = "up"
const DOWN = "down"
const LEFT = "left"
const RIGHT = "right"

const GROUND = "ma"
const PLAYER = "soweli"

const init_map = [
	[1,1,1,1,1,1,1,1,1,1,1,1],
	[1,0,0,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,1,0,0,0,0,0,1],
	[1,0,0,0,1,0,1,0,0,0,0,1],
	[1,0,0,0,0,1,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,0,0,1],
	[1,1,1,1,1,1,1,1,1,1,1,1],
]

var map = init_map.duplicate(true)
var map_height = map.size()
var map_width = map[0].size()

var player_pos: Vector2 = Vector2(2, 2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map[player_pos.y][player_pos.x] = 2
	reset_map()


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

func update_player(input_dir: Vector2):
	map[player_pos.y][player_pos.x] = init_map[player_pos.y][player_pos.x]
	player_pos += input_dir
	if map[player_pos.y][player_pos.x] != 0:
		player_pos -= input_dir
	$Camera.position = player_pos * 64 + Vector2(32, 32)
	map[player_pos.y][player_pos.x] = 2
	reset_map()

func reset_map():
	var map_text: String = ""
	for row in range(0, map.size()):
		for col in range(0, map[row].size()):
			var item = map[row][col]
			match item:
				0: map_text += GROUND
				1: map_text += "ijo"
				2: map_text += PLAYER
				_: 
					map_text += "seme"
					print("Symbol %s not defined at row %s, col %s" % [item, row, col])
			map_text += "|"
		map_text += "\n"
	
	$Map.text = map_text
