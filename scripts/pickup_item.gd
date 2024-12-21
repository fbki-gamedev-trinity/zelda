extends Area2D

class_name PickUpItem

@export var inventry_item: InventoryItem
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var stacks: int = 1
@export var id: String = ""

var is_alive: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.texture = inventry_item.texture
	collision_shape_2d.shape = inventry_item.ground_collision_shape
	is_alive = TransitionChangeManager.load_state(self.id + "_pickup")
	if not is_alive:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		TransitionChangeManager.save_state(self.id + "_pickup", false)
		body.add_item_to_inventory(inventry_item, stacks)
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func disable_collision():
	collision_shape_2d.disabled = true
	
func enable_collision():
	collision_shape_2d.disabled = false
