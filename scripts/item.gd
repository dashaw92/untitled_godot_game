class_name Item

static var SPRITES = preload("res://graphics/items.png")
static var CELL_SIZE = 16
static var WIDTH = SPRITES.get_width() / CELL_SIZE

static var atlas = []
# Generates the sprite atlas from the spritesheet.
# Contents of atlas are populated based off the ItemType
# enum, so for a texture to be used, there most be an
# ItemType constant associated to that cell in the sheet.
static func generateSprites():
	atlas.resize(ItemType.values().size())
	for type in ItemType.values():
		var x = (type % WIDTH) * CELL_SIZE
		var y = (type / WIDTH) * CELL_SIZE
		var rect = Rect2i(x, y, CELL_SIZE, CELL_SIZE)
		
		var tex = AtlasTexture.new()
		tex.atlas = SPRITES
		tex.region = rect
		atlas[type] = tex

static func getSprite(item: ItemType) -> AtlasTexture:
	if atlas.is_empty():
		generateSprites()
	
	return atlas[item]

# Items correspond to textures via the ordering of these constants
# The first item is the first texture in the atlas at 0, 0, and the
# following is at 16, 0, so on
enum ItemType {
	Pickaxe,
	Sword,
}
