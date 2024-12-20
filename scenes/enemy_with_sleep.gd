extends CharacterBody2D

class_name Enemy_wood

@export var speed: float = 100
@export var patrol_path: Array[Marker2D] = []
@export var patrol_wait_time = 0.2
@export var damage_to_player = 10
@export var detection_distance: float = 150 # Дистанция, на которой враг просыпается

@export var id: String = ""

@export var health: int = 50
@export var item_to_drop: InventoryItem

@onready var animated_sprite_2d: EnemyAnimatedSprite2D = $AnimatedSprite2D
@onready var health_system: HealthSystem = $HealthSystem
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@export var loot_stacks = 1
@onready var player = $"../Player"

const PICKUP_ITEM_SCENE = preload("res://scenes/pickup_item.tscn") # для моентки с врага

var current_patrol_target = 0
var wait_timer = 0.0
var is_awake = false # Переменная для отслеживания состояния врага

var is_alive: bool = true


func _ready() -> void:
	health_system.init(health)
	progress_bar.max_value = health
	progress_bar.value = health
	if patrol_path.size() > 0:
		position = patrol_path[0].position
	health_system.died.connect(on_died)

	is_alive = TransitionChangeManager.load_state(self.id)
	if not is_alive:
		queue_free()

	# При загрузке сцены враг сразу спит
	animated_sprite_2d.play("sleep")

func _physics_process(delta: float) -> void:
	var distance_to_player = position.distance_to(player.position)

	# Если игрок в пределах зоны обнаружения, враг просыпается
	if distance_to_player < detection_distance and not is_awake:
		is_awake = true
		animated_sprite_2d.play("wake_up") # Анимация просыпания
	elif distance_to_player >= detection_distance and is_awake:
		is_awake = false
		animated_sprite_2d.play("sleep") # Анимация сна

	if is_awake and patrol_path.size() > 1:
		move_along_path(delta)

func apply_damage(damage: int):
	health_system.apply_damage(damage)

func move_along_path(delta: float):
	var target_position = patrol_path[current_patrol_target].global_position
	var direction = (target_position - position).normalized()
	var distance_to_target = position.distance_to(target_position)
	
	if distance_to_target > speed * delta:
		animated_sprite_2d.play_movement_animation(direction)
		velocity = direction * speed 
		move_and_slide()
	else: 
		animated_sprite_2d.play_idle_animation()
		position = target_position
		wait_timer += delta
		if wait_timer >= patrol_wait_time:
			wait_timer = 0.0
			current_patrol_target = (current_patrol_target + 1) % patrol_path.size()

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
		loot_drop.stacks = loot_stacks
		
		get_tree().root.add_child(loot_drop)
		loot_drop.global_position = position
		queue_free()
