extends CharacterBody2D

const SPEED = 750
enum Facing {
	left = 0,
	right = 1,
	front = 2,
	back = 3,
}
const FacingToString: Array = [
	"left", "right", "front", "back"
]

var changedDirection = false
var facing: Facing = Facing.front
var walking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	var zoom = Input.get_axis("zoom_out", "zoom_in")
	$Camera2D.zoom += Vector2(zoom / 10, zoom / 10)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dx = Input.get_axis("ui_left", "ui_right")
	var dy = Input.get_axis("ui_up", "ui_down")
	
	if (dx == 0 and dy == 0):
		walking = false
	else:
		walking = true
		match [dx, dy]:
			[var x, _] when x < 0:
				facing = Facing.left
			[var x, _] when x > 0:
				facing = Facing.right
			[_, var y] when y < 0:
				facing = Facing.back
			[_, var y] when y > 0:
				facing = Facing.front
	
	velocity = Vector2(dx, dy)
	if(abs(dx) + abs(dy) > 1):
		velocity = velocity.normalized()
		
	velocity *= delta * SPEED
	move_and_collide(velocity)
	
	animate()

	pass


func animate() -> void:
	var currentAnim = $AnimatedSprite2D.animation
	var anim: String
	
	if (walking):
		anim = "walk_" + FacingToString[facing]
	else:
		anim = "idle_" + FacingToString[facing]
	
	if (anim == currentAnim):
		pass
	$AnimatedSprite2D.play(anim)
