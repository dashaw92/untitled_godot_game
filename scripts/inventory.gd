class_name Inventory extends Node2D

const UI_SIZE = 16

## Number of slots the player has
@export var slots: int = 6
## Max item stack count, or -1 for unlimited (max int)
@export var stackSize: int = -1

@export var texture: Texture2D

var contents = []
var selected = 0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	var item_select = int(Input.get_axis("inv_prev", "inv_next"))
	if item_select == 0:
		pass
	
	if selected == 0 and item_select == -1:
		selected = slots - 1
	else:
		selected += item_select
	selected %= slots
	update()

func update():
	queue_redraw()

func _draw() -> void:
	for i in range(slots):
		var local_x = i * UI_SIZE - slots * UI_SIZE / 2
		var local_y = 40
		if i == selected:
			draw_rect(Rect2i(local_x, local_y, UI_SIZE, UI_SIZE), Color.SILVER)
		draw_texture(texture, Vector2(local_x, local_y))
