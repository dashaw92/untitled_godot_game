extends Node2D

@export var WIDTH = 500
@export var HEIGHT = 500
@export var MIN_ROOMS = 30
@export var MAX_ROOMS = 100
@export var ROOM_MAX_WIDTH = 40
@export var ROOM_MAX_HEIGHT = 40
@export var ROOM_MIN_WIDTH = 15
@export var ROOM_MIN_HEIGHT = 10

@onready var ground = $Ground
@onready var walls = $Walls

const WALL_NW = Vector2i(6, 2)
const WALL_NE = Vector2i(5, 2)
const WALL_N = Vector2i(4, 2)
const WALL_E = Vector2i(3, 2)
const WALL_S = Vector2i(1, 2)
const WALL_W = Vector2i(2, 2)
const WALL_SW = Vector2i(8, 2)
const WALL_SE = Vector2i(7, 2)

const DIRT_FLOOR = Vector2i(0, 3)
const STONE_FLOOR = Vector2i(0, 2)

var spawnRoom = null

var Room = load("res://scripts/room.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var numRooms = randi_range(MIN_ROOMS, MAX_ROOMS)
	var rooms = []
	var retries = 0
	while rooms.size() != numRooms:
		print(rooms.size(), " / ", numRooms)
		var x = randi_range(1, WIDTH - 1)
		var y = randi_range(1, WIDTH - 1)
		var w = randi_range(ROOM_MIN_WIDTH, ROOM_MAX_WIDTH)
		var h = randi_range(ROOM_MIN_WIDTH, ROOM_MAX_WIDTH)
		var room = Room.new(x, y, w, h)
		
		var collides = false
		for r in rooms:
			if (room.intersects(r)):
				collides = true
				break
		if (collides):
			retries += 1
			if (retries > 15):
				break
			continue
		
		retries = 0
		rooms.append(room)
		
		if (spawnRoom == null):
			spawnRoom = room
		placeRoom(room)
	
	if(rooms.size() > 1):
		var connections = 0
		while(connections < rooms.size()):
			var first = rooms.pick_random()
			var other = rooms.pick_random()
			if (other.x == first.x and other.y == first.y):
				continue
			
			connectRooms(first, other)
			connections += 1
	
	$Player.position = Vector2((spawnRoom.x * 16) + (spawnRoom.width / 2 * 16), (spawnRoom.y * 16) + (spawnRoom.height / 2 * 16))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func placeRoom(room: Room) -> void:
	for x in range(room.x, room.x + room.width):
		for y in range(room.y, room.y + room.height):
			var cell
			ground.set_cell(Vector2i(x, y), 0, DIRT_FLOOR)
			if (x == room.x):
				if (y == room.y):
					cell = WALL_NW
				elif (y + 1 == room.y + room.height):
					cell = WALL_SW
				else:
					cell = WALL_W
			elif (x + 1 == room.x + room.width):
				if (y == room.y):
					cell = WALL_NE
				elif (y + 1 == room.y + room.height):
					cell = WALL_SE
				else:
					cell = WALL_E
			elif (y == room.y):
				cell = WALL_N
			elif (y + 1 == room.y + room.height):
				cell = WALL_S
			else:
				continue
			walls.set_cell(Vector2i(x, y), 0, cell)

func connectRooms(a: Room, b: Room) -> void:
	var start = pickRandomDoor(a)
	var end = pickRandomDoor(b)
	
	for x in range(start.x, end.x):
		ground.set_cell(Vector2i(x, start.y), 0, STONE_FLOOR)
		walls.set_cell(Vector2i(x, start.y), -1)
	
	for y in range(start.y, end.y):
		ground.set_cell(Vector2i(end.x, y), 0, STONE_FLOOR)
		walls.set_cell(Vector2i(end.x, y), -1)
	
	pass

func pickRandomDoor(a: Room) -> Vector2i:
	var start
	var rand = randi_range(0, 100)
	match rand:
		var i when i < 25:
			start = Vector2i(a.x, a.y + (a.height / 2))
		var i when i < 50:
			start = Vector2i(a.x + (a.width / 2), a.y)
		var i when i < 75:
			start = Vector2i(a.x + a.width, a.y + (a.height / 2))
		_:
			start = Vector2i(a.x + (a.width / 2), a.y + a.height)
	return start
