class_name Inventory extends Node2D

#const Item = preload("res://scripts/item.gd")
const UI_SIZE = 16

## Number of slots the player's backpack has
@export var numBackpackSlots: int = 24
## Number of slots the player's quick access bar has
@export var numHotbarSlots: int = 6
## Max item stack count, or -1 for unlimited (max int)
@export var stackSize: int = -1

@export var texture: Texture2D

# Indexable via Item.ItemType. Value is number of that ItemType held. Init = 0 = none held
var contents = []
# Placement of items in inventory
# Size is numBackpackSlots + numHotbarSlots. Quick access bar is 0..numHotbarSlots, numHotbarSlots..numBackpackSlots is backpack
# init = -1 = empty slot, as 0 is the first ItemType constant
var slots = []
var selected = 0
var backpackOpen = false

func _ready() -> void:
	# Initialize contents and slots to valid defaults, ensuring
	# both are large enough to represent an inventory.
	# contents must have parity with ItemType.values()
	contents.resize(Item.ItemType.values().size())
	# default init for contents is 0, meaning none of that item held
	contents.fill(0)
	# slots represents the entire inventory, with the first
	# numHotbarSlots being for the hotbar, and the rest for the backpack
	slots.resize(numHotbarSlots + numBackpackSlots)
	# -1 means empty slot
	slots.fill(-1)
	
	# TODO remove
	addItem(Item.ItemType.Sword)
	addItem(Item.ItemType.Pickaxe)
	pass

# Adds the item to the inventory, and also populates
# the first empty slot in slots to point to that item
# unless the item is already held in slots
func addItem(item: Item.ItemType, count: int = 1) -> bool:
	contents[item] += min(1, count)
	
	var firstEmpty = -1
	for i in range(numHotbarSlots):
		# If the item already has a slot, there
		# is no need to place it somewhere else, but
		# the text showing the count must be updated.
		if slots[i] == item:
			update()
			return true
		
		# Scan for the first empty slot.
		# Do not terminate the loop because the item
		# might already have a place in the inventory (above)
		if firstEmpty == -1 and slots[i] == -1:
			firstEmpty = i
			continue
	
	# If there are no empty spots, then the item cannot be added
	if firstEmpty == -1:
		return false
	
	# If this is reached, the item is currently not in any of the slots.
	# Use the first empty slot
	slots[firstEmpty] = item
	update()
	return true
	
func removeItem(item: Item.ItemType, count: int = 1) -> void:
	contents[item] = max(0, contents[item] - count)
	
	if contents[item] == 0:
		for i in slots.size():
			if i == item:
				slots[i] = -1
				break

func update():
	queue_redraw()

func _input(event: InputEvent) -> void:
	var item_select = int(Input.get_axis("inv_prev", "inv_next"))
	if item_select == 0:
		pass
	
	if selected == 0 and item_select == -1:
		selected = numHotbarSlots - 1
	else:
		selected += item_select
	selected %= numHotbarSlots
	update()

func _draw() -> void:
	for i in range(numHotbarSlots):
		var local_x = i * UI_SIZE - numHotbarSlots * UI_SIZE / 2
		var local_y = 40
		draw_texture(texture, Vector2(local_x, local_y))
		
		if slots[i] != -1:
			var item = slots[i] as Item.ItemType
			draw_texture(Item.getSprite(item), Vector2(local_x, local_y))
			
		if i == selected:
			draw_rect(Rect2i(local_x, local_y, UI_SIZE, UI_SIZE), Color(Color.SILVER, 0.4))
