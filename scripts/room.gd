class_name Room

var x
var y
var width
var height
		
var connections: int:
	set(v):
		connections = clampi(v, 0, 4)
		
func isConnected() -> bool:
	return connections > 0

func _init(x: int, y: int, width: int, height: int):
	self.x = x
	self.y = y
	self.width = width
	self.height = height

func intersects(other: Room) -> bool:
	if (x + width < other.x):
		return false
	if (x > other.x + other.width):
		return false
	if (y + height < other.y):
		return false
	if (y > other.y + other.height):
		return false
		
	return true
