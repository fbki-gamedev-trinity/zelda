extends CharacterBody2D

class_name Player
	
const SPEED = 3000.0

@onready var animated_sprite_2d: AnimationController = $AnimatedSprite2D
@onready var inventory: Inventory = $inventory
@onready var health_system: HealthSystem = $HealthSystem
@onready var on_screen_ui: OnScreenUI = $onScreenUI
@onready var combat_system: CombatSystem = $CombatSystem
@onready var camera: Camera2D = $Camera2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@export var health = 100
var is_dead = false

func _ready() -> void:
	health_system.init(health)
	health_system.died.connect(on_player_dead)
	health_system.damage_taken.connect(on_damage_taken)
	on_screen_ui.init_health_bar(health)


func sync_inventory_with_manager():
	inventory.remove_items()
	for item in PlayerInventoryManager.get_inventory():
		inventory.add_item(item["item"], item["amount"])
	print(inventory.get_items())
	var equip = PlayerInventoryManager.equip
	for key in equip.keys():
		if key == "Spell":
			inventory.on_spell_slot_clicked(equip.get(key))
		elif key == "Arrow":
			inventory.on_arrow_slot_clicked(equip.get(key))
		else:
			inventory.on_item_equipped(equip.get(key), key)
	combat_system.left_hand_weapon_sprite.visible = false
	combat_system.right_hand_weapon_sprite.visible = false

func _physics_process(delta: float) -> void:
	if animated_sprite_2d.animation.contains("attack"):
		return

	var direction = Input.get_vector("left", "right", "up", "down")

	# Запрещаем движение по диагонали
	#if direction.x != 0 and direction.y != 0:
		#direction.y = 0  # Отдаем приоритет горизонтальному движению

	if direction:
		velocity = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)

	if velocity != Vector2.ZERO:
		animated_sprite_2d.play_movement_animation(velocity)
	else:
		animated_sprite_2d.play_idle_animation()
	#var collision = move_and_collide(velocity * delta)
	#if collision:
		#velocity = velocity.bounce(collision.get_position())
	move_and_slide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is PickUpItem:
		inventory.add_item(area.inventry_item, area.stacks)
		PlayerInventoryManager.add_item(area.inventry_item, area.stacks)
		
		area.is_alive = false
		TransitionChangeManager.save_state(area.id, area.is_alive)
		area.queue_free()

		
	if area.get_parent() is Enemy:
		var damage_to_player = (area.get_parent() as Enemy).damage_to_player
		health_system.apply_damage(damage_to_player)

func on_damage_taken(damage: int) -> void:
	on_screen_ui.apply_damage_to_health_bar(damage)

func on_player_dead():
	set_physics_process(false)
	combat_system.set_process_input(false)
	collision_shape_2d.set_deferred("disabled", true) 
	area_collision_shape_2d.set_deferred("disabled", true) 
	animated_sprite_2d.play_dead_animation()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	
