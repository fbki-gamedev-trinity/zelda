extends CharacterBody2D

class_name DestroyedObject

@export var health: int = 120
@export var item_to_drop: InventoryItem
@export var id: String = ""
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_system: HealthSystem = $HealthSystem
@onready var progress_bar: ProgressBar = $ProgressBar

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@export var stacks = 1

const PICKUP_ITEM_SCENE = preload("res://scenes/pickup_item.tscn") # для моентки с врага
var is_alive: bool = true

func _ready() -> void:
	health_system.init(health)
	progress_bar.max_value = health
	progress_bar.value = health

	health_system.died.connect(on_died)
	is_alive = TransitionChangeManager.load_state(self.id)
	if not is_alive:
		queue_free()


func apply_damage(damage: int):
	health_system.apply_damage(damage)

func on_died():
	is_alive = false
	TransitionChangeManager.save_state(id, is_alive)
	set_physics_process(false)
	collision_shape_2d.set_deferred("disabled", true) 
	area_collision_shape_2d.set_deferred("disabled", true) 
	animated_sprite_2d.play("died")
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "died":
		var loot_drop = PICKUP_ITEM_SCENE.instantiate() as PickUpItem
		loot_drop.inventry_item = item_to_drop
		loot_drop.stacks = stacks
		print("Pick up ", loot_drop)
		print("Item from obj ", item_to_drop)
		loot_drop.global_position = position
		get_tree().root.add_child(loot_drop)
		queue_free()
		

	
