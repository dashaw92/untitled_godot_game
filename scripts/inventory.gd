class_name Inventory extends Node2D

#const Item = preload("res://scripts/item.gd")
const UI_SIZE = 16

## Number of slots the player's backpack has
@export var numBackpackSlots: int = 24
## Number of slots the player's quick access bar has
@export var numSlots: int = 6
## Max item stack count, or -1 for unlimited (max int)
@export var stackSize: int = -1

@export var texture: Texture2D

# Indexable via Item.ItemType. Value is number in inventory
var contents = []
# Placement of items in inventory
# Size is numBackpackSlots + numSlots. Quick access bar is 0..numSlots, numSlots..numBackpackSlots is backpack
var slots = []
var selected = 0
var backpackOpen = false

func _ready() -> void:
	contents.resize(Item.ItemType.values().size())
	contents.fill(0)
	slots.resize(numSlots + numBackpackSlots)
	slots.fill(-1)
	
	addItem(Item.new(Item.ItemType.Sword))
	addItem(Item.new(Item.ItemType.Pickaxe))
	pass
	
func _process(delta: float) -> void:
	pass

func addItem(item: Item) -> void:
	contents[item.type] += 1
	
	for i in range(numSlots):
		if slots[i] == -1:
			slots[i] = item.type
			update()
			return
	
func removeItem(item: Item, count: int = 1) -> void:
	contents[item.type] = max(0, contents[item.type] - count)
	
	if contents[item.type] == 0:
		for i in slots.size():
			if i == item.type:
				slots[i] = -1
				break

func _input(event: InputEvent) -> void:
	var item_select = int(Input.get_axis("inv_prev", "inv_next"))
	if item_select == 0:
		pass
	
	if selected == 0 and item_select == -1:
		selected = numSlots - 1
	else:
		selected += item_select
	selected %= numSlots
	update()

func update():
	queue_redraw()

func _draw() -> void:
	for i in range(numSlots):
		var local_x = i * UI_SIZE - numSlots * UI_SIZE / 2
		var local_y = 40
		draw_texture(texture, Vector2(local_x, local_y))
		
		if slots[i] != -1:
			var item = slots[i] as Item.ItemType
			draw_texture(Item.getSprite(item), Vector2(local_x, local_y))
			
		if i == selected:
			draw_rect(Rect2i(local_x, local_y, UI_SIZE, UI_SIZE), Color(Color.SILVER, 0.4))
