extends Area2D

class_name PickUpItem

@export var inventry_item: InventoryItem
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var stacks: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.texture = inventry_item.texture
	collision_shape_2d.shape = inventry_item.ground_collision_shape


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func disable_collision():
	collision_shape_2d.disabled = true
	
func enable_collision():
	collision_shape_2d.disabled = false
