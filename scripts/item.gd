static var SPRITES = preload("res://graphics/items.png")
static var CELL_SIZE = 16
static var WIDTH = SPRITES.get_width() / CELL_SIZE

static var atlas = []
static func generateSprites():
	for type in ItemType.values():
		var x = (type % WIDTH) * CELL_SIZE
		var y = (type / WIDTH) * CELL_SIZE
		var rect = Rect2i(x, y, CELL_SIZE, CELL_SIZE)
		
		var tex = AtlasTexture.new()
		tex.atlas = SPRITES
		tex.region = rect
		atlas.append(tex)

func getSprite(item: ItemType) -> AtlasTexture:
	if atlas.is_empty():
		generateSprites()
	
	return atlas[item]

class Item:
	var type: ItemType
	
	func _init(type: ItemType) -> void:
		self.type = type

enum ItemType {
	Sword = 0
}
