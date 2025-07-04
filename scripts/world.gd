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
	
	var astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, WIDTH, HEIGHT)
	astar.cell_size = Vector2(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()
	
	var rooms = []
	var retries = 0
	while rooms.size() != numRooms:
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
		placeRoom(room, astar)
	
	if(rooms.size() > 1):
		var connections = 0
		while(connections < rooms.size()):
			var first = rooms.pick_random()
			var other = rooms.pick_random()
			if (other.x == first.x and other.y == first.y):
				continue
			
			connectRooms(first, other, astar)
			connections += 1
	
	$Player.position = Vector2((spawnRoom.x * 16) + (spawnRoom.width / 2 * 16), (spawnRoom.y * 16) + (spawnRoom.height / 2 * 16))


func placeRoom(room: Room, astar: AStarGrid2D) -> void:
	astar.fill_solid_region(Rect2i(room.x - 1, room.y - 1, room.width + 2, room.height + 2))
	
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

func connectRooms(a: Room, b: Room, astar: AStarGrid2D) -> void:
	var start = pickRandomDoor(a, astar)
	var end = pickRandomDoor(b, astar)
	
	var points = astar.get_point_path(start, end)
	for point in points:
		astar.set_point_solid(point)
		ground.set_cell(point, 0, STONE_FLOOR)
		walls.set_cell(point, -1)
	
	a.connections += 1
	b.connections += 1
	pass

func pickRandomDoor(a: Room, astar: AStarGrid2D) -> Vector2i:
	# One of four midpoints on the walls of the room (N, E, S, W)
	var start
	# All rooms have a 1 tile border expanding around them that
	# is marked as solid in the astar grid. This must be set to
	# non-solid for paths to work
	var pathOut
	var rand = randi_range(0, 100)
	match rand:
		var i when i < 25:
			# West door
			start = Vector2i(a.x, a.y + (a.height / 2))
			pathOut = Vector2i(a.x - 1, start.y)
		var i when i < 50:
			# North (top) door
			start = Vector2i(a.x + (a.width / 2), a.y)
			pathOut = Vector2i(start.x, start.y - 1)
		var i when i < 75:
			# East door
			start = Vector2i(a.x + a.width - 1, a.y + (a.height / 2))
			pathOut = Vector2i(start.x + 1, start.y)
		_:
			# South door
			start = Vector2i(a.x + (a.width / 2), a.y + a.height - 1)
			pathOut = Vector2i(start.x, start.y + 1)
			
	astar.set_point_solid(start, false)
	astar.set_point_solid(pathOut, false)
	return start
